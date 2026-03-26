extends Node

# ==========================================
# 核心配置参数
# ==========================================
const MAX_SFX_PLAYERS = 32 ## 音效对象池大小（可根据需要增减）
const MIN_DB = -80.0 ## 静音的绝对分贝值

# ==========================================
# 内部状态追踪容器
# ==========================================
var _sfx_pool: Array[AudioStreamPlayer] = [] # 闲置喇叭池
var _active_sfx_players: Array[AudioStreamPlayer] = [] # 正在发声的喇叭列表

# 字典：记录当前正在播放的 Event 及其对应的喇叭和属性
# 结构：AudioStreamPlayer -> { "event": AudioEvent, "priority": int, "tween": Tween }
var _player_states: Dictionary = {} 

# 字典：用于并发控制，记录某个 Event 当前有几个实例正在发声
# 结构：AudioEvent -> int (活跃数量)
var _event_play_counts: Dictionary = {}

# BGM 双唱片机系统
var _bgm_players: Array[AudioStreamPlayer] = []
var _current_bgm_idx: int = 0
var _bgm_tween: Tween = null # 用于控制BGM交叉淡入淡出

# ==========================================
# 初始化 (基建与造轮子)
# ==========================================
func _ready() -> void:
	# 1. 制造 SFX 喇叭池
	for i in range(MAX_SFX_PLAYERS):
		var p = AudioStreamPlayer.new()
		add_child(p)
		p.finished.connect(_on_sfx_finished.bind(p)) # 绑定自然播放结束的信号
		_sfx_pool.append(p)
		
	# 2. 制造 BGM 双通道喇叭
	for i in range(2):
		var p = AudioStreamPlayer.new()
		p.bus = &"BGM" # 强制走 BGM 总线
		add_child(p)
		_bgm_players.append(p)


# ==========================================
# SFX 播放黑盒核心逻辑
# ==========================================
func play_sfx(event: AudioEvent) -> void:
	if not event or event.clips.is_empty():
		return
		
	# 【防线 1：并发拦截】
	var current_count = _event_play_counts.get(event, 0)
	if current_count >= event.max_instances:
		return # 拦截：同屏该声音已达上限，静默丢弃
		
	# 【获取喇叭与抢占逻辑】
	var player = _get_available_player(event.priority)
	if not player:
		return # 拦截：池子满了，且当前声音优先级太低没抢过别人
		
	# 【数据提纯】
	var valid_clips = event.clips.filter(func(c): return c != null and c.stream != null)
	if valid_clips.is_empty():
		_recycle_player(player) # 发现是空壳，把喇叭还回去
		return
		
	var clip: AudioClipData = valid_clips.pick_random()
	
	# 【状态注册】
	_event_play_counts[event] = current_count + 1
	_active_sfx_players.append(player)
	
	var tween = create_tween()
	_player_states[player] = {
		"event": event,
		"priority": event.priority,
		"tween": tween
	}
	
	# 【参数装填】
	player.stream = clip.stream
	player.bus = event.bus_name
	
	# 最终倍速 = (事件基础倍速 * 切片独立倍速) + 随机波动
	var target_pitch = (event.base_pitch * clip.pitch_multiplier) + randf_range(-event.pitch_randomness, event.pitch_randomness)
	# 限制极值，防止引擎报错 (Godot的pitch_scale必须大于0)
	player.pitch_scale = clamp(target_pitch, 0.01, 4.0) 
	
	var target_volume = event.base_volume_db + clip.volume_offset_db
	
	# 【执行非破坏性剪辑 (Tween)】
	if clip.fade_in > 0:
		player.volume_db = MIN_DB
		tween.tween_property(player, "volume_db", target_volume, clip.fade_in)
	else:
		player.volume_db = target_volume
		
	player.play(clip.start_time) # 空降到剪辑起点
	
	# 如果策划填了持续时间，就按时掐断
	if clip.duration == 0:
		clip.duration = clip.stream.get_length()
	if clip.duration > 0:
		tween.tween_interval(clip.duration)
		if clip.fade_out > 0:
			tween.tween_property(player, "volume_db", MIN_DB, clip.fade_out)
		# 动画结束时强制回收喇叭
		tween.tween_callback(func(): _recycle_player(player))
		

# 获取闲置喇叭，或通过“末位淘汰”抢占一个喇叭
func _get_available_player(new_priority: int) -> AudioStreamPlayer:
	if not _sfx_pool.is_empty():
		return _sfx_pool.pop_back()
		
	# 池子空了，触发抢占机制
	var lowest_priority = 9999
	var victim_player: AudioStreamPlayer = null
	
	for p in _active_sfx_players:
		var p_priority = _player_states[p]["priority"]
		if p_priority < lowest_priority:
			lowest_priority = p_priority
			victim_player = p
			
	# 如果最低优先级的那个，比我们新来的事件优先级低，果断抢占！
	if victim_player and lowest_priority < new_priority:
		_recycle_player(victim_player) # 强行终止并回收被抢的喇叭
		return _sfx_pool.pop_back() # 拿出来给新声音用
		
	return null

# 音频自然播放完毕的信号回调
func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	_recycle_player(player)

# 核心回收机制（重置状态，归还池子）
func _recycle_player(player: AudioStreamPlayer) -> void:
	if player in _sfx_pool: return # 已经回收过了，防止二次调用
	
	player.stop() # 停止发声
	
	if _player_states.has(player):
		var state = _player_states[player]
		# 杀掉残留的补间动画
		if state["tween"] and state["tween"].is_valid():
			state["tween"].kill()
			
		# 更新并发计数器
		var evt = state["event"]
		if _event_play_counts.has(evt):
			_event_play_counts[evt] -= 1
			if _event_play_counts[evt] <= 0:
				_event_play_counts.erase(evt)
				
		_player_states.erase(player)
		
	_active_sfx_players.erase(player)
	_sfx_pool.append(player) # 擦干净，丢回可用池


# ==========================================
# BGM 播放黑盒核心逻辑 (双唱机模型)
# ==========================================
## 播放新的 BGM。crossfade_time 为交叉淡入淡出所需的时间（秒）
func play_bgm(stream: AudioStream, crossfade_time: float = 2.0) -> void:
	var current_player = _bgm_players[_current_bgm_idx]
	
	# 如果已经在播同一首歌，且没有静音，直接忽略
	if current_player.stream == stream and current_player.playing:
		return 
		
	# 切换到另一个唱机
	var next_idx = 1 - _current_bgm_idx
	var next_player = _bgm_players[next_idx]
	
	next_player.stream = stream
	next_player.volume_db = MIN_DB
	next_player.play()
	
	# 杀掉之前的过渡动画（如果还在过渡的话）
	if _bgm_tween and _bgm_tween.is_valid():
		_bgm_tween.kill()
		
	_bgm_tween = create_tween()
	_bgm_tween.set_parallel(true) # 允许同时进行音量升和降
	
	# 当前唱机淡出，下一台唱机淡入
	_bgm_tween.tween_property(current_player, "volume_db", MIN_DB, crossfade_time)
	_bgm_tween.tween_property(next_player, "volume_db", 0.0, crossfade_time)
	
	# 动画结束后把旧唱机彻底停掉，节省性能
	_bgm_tween.chain().tween_callback(current_player.stop)
	
	_current_bgm_idx = next_idx

## 停止当前的 BGM
func stop_bgm(fade_out_time: float = 1.0) -> void:
	var current_player = _bgm_players[_current_bgm_idx]
	if not current_player.playing: return
	
	if _bgm_tween and _bgm_tween.is_valid():
		_bgm_tween.kill()
		
	_bgm_tween = create_tween()
	_bgm_tween.tween_property(current_player, "volume_db", MIN_DB, fade_out_time)
	_bgm_tween.tween_callback(current_player.stop)