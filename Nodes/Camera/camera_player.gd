extends Camera2D

@export_group("Follow & Transition")
@export var target_node: Node2D # 目标玩家
@export var follow_speed: float = 5.0 # 跟随速度
@export var transition_time: float = 0.5 # 房间过渡时间

@export_group("Advanced Shake")
# 噪声频率：值越大，震动得越快（越“碎”）；值越小，震动越慢（越“晃”）
@export var noise_frequency: float = 10.0 
# 噪声衰减曲线：控制震动如何从最强慢慢减弱到 0。建议设置为Ease Out类型
@export var shake_decay_curve: Curve

# ==============================
# 内部变量
# ==============================
# 房间过渡相关
var is_transitioning: bool = false
var _transition_tween: Tween

# 震动相关核心
var _noise = FastNoiseLite.new()
var _active_shakes: Array[ShakeInstance] = []
var _noise_timer: float = 0.0

# --------------------------------------------------------------
# 内部类：定义单个震动实例
# --------------------------------------------------------------
class ShakeInstance:
	var strength: Vector2   # 初始强度
	var duration: float     # 总持续时间
	var time_left: float    # 剩余时间
	var noise_y_offset: float # 该实例在噪声图上的唯一Y轴偏移，防止多个震动轨迹重复
	
	func _init(s: Vector2, d: float):
		strength = s
		duration = d
		time_left = d
		# 随机一个Y偏移，让每次震动的轨迹都不同
		noise_y_offset = randf_range(0, 1000.0)

# ==============================
# 生命周期与核心逻辑
# ==============================
func _ready():
	# 基础设置
	limit_smoothed = true 
	position_smoothing_enabled = false
	
	# 初始化噪声生成器
	_noise.seed = randi()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = 0.5 # 基础频率，实际表现由脚本里的 noise_frequency 控制
	
	# 连接 EventBus 信号 (假设全局单例叫 EventBus)
	if has_node("/root/EventBus"):
		var eb = get_node("/root/EventBus")
		if eb.has_signal("camera_shake"):
			eb.camera_shake.connect(_on_camera_shake)
		else:
			printerr("Camera2D Error: EventBus is found but signal 'camera_shake' is missing.")
	else:
		printerr("Camera2D Error: Autoload singleton 'EventBus' not found.")


func _physics_process(delta: float) -> void:
	# 1. 处理高级叠加震动
	_process_shake_stack(delta)
	
	# 2. 处理原有的跟随逻辑
	if is_transitioning or not target_node:
		return
	
	# 平滑跟随玩家 (使用 global_position)
	global_position = global_position.lerp(target_node.global_position, follow_speed * delta)


# ==============================
# 震动系统核心实现
# ==============================

# 接收信号的槽函数
func _on_camera_shake(strength: Vector2, duration: float):
	# 实例化一个新的震动，压入栈中 (实现了可叠加)
	var new_shake = ShakeInstance.new(strength, duration)
	_active_shakes.append(new_shake)


# 每帧处理震动栈
func _process_shake_stack(delta: float):
	if _active_shakes.is_empty():
		# 如果没有震动，确保 offset 归零，不影响正常跟随
		if offset != Vector2.ZERO:
			offset = Vector2.ZERO
		return

	# 累加噪声时间戳 (让噪声动起来)
	_noise_timer += delta * noise_frequency
	
	var total_offset = Vector2.ZERO
	# 使用倒序遍历，方便在循环内部删除过期的实例
	for i in range(_active_shakes.size() - 1, -1, -1):
		var shake = _active_shakes[i]
		
		# 更新剩余时间
		shake.time_left -= delta
		
		# 如果震动结束，移除它
		if shake.time_left <= 0:
			_active_shakes.remove_at(i)
			continue
		
		# --- 计算当前实例的贡献 ---
		
		# 1. 计算归一化的进度 (0.0 -> 1.0)
		var progress = 1.0 - (shake.time_left / shake.duration)
		
		# 2. 计算衰减系数 (使用 Curve)
		var decay_factor = 1.0
		if shake_decay_curve:
			decay_factor = shake_decay_curve.sample(progress)
		else:
			decay_factor = 1.0 - progress # 如果没配Curve，默认线性衰减
			
		# 3. 采样柏林噪声 (产生平滑的 -1 到 1 之间的值)
		# 我们使用 _noise_timer 作为X轴，实例唯一的 noise_y_offset 作为Y轴
		var noise_raw_x = _noise.get_noise_2d(_noise_timer, shake.noise_y_offset)
		var noise_raw_y = _noise.get_noise_2d(shake.noise_y_offset, _noise_timer) # 交换一下，让XY不同步
		
		# 4. 计算最终偏移：噪声 (-1~1) * 初始强度 * 衰减
		var current_shake_offset = Vector2(
			noise_raw_x * shake.strength.x * decay_factor,
			noise_raw_y * shake.strength.y * decay_factor
		)
		
		# 5. 叠加到总偏移
		total_offset += current_shake_offset

	# 应用最终叠加后的偏移
	offset = total_offset

# ==============================
# 原有的房间过渡逻辑 (保持不变)
# ==============================
func transition_to_room(boundary, room_global_pos: Vector2):
	is_transitioning = true
	
	if _transition_tween:
		_transition_tween.kill()
	
	var new_l = int(room_global_pos.x + boundary.left)
	var new_r = int(room_global_pos.x + boundary.right)
	var new_t = int(room_global_pos.y + boundary.top)
	var new_b = int(room_global_pos.y + boundary.bottom)
	
	var view_size = get_viewport_rect().size / zoom
	var half_view = view_size / 2.0
	
	var target_x = clamp(target_node.global_position.x, new_l + half_view.x, new_r - half_view.x)
	var target_y = clamp(target_node.global_position.y, new_t + half_view.y, new_b - half_view.y)
	var target_pos = Vector2(target_x, target_y)

	_transition_tween = create_tween()
	_transition_tween.set_parallel(true)
	_transition_tween.set_ease(Tween.EASE_OUT)
	_transition_tween.set_trans(Tween.TRANS_CUBIC)
	
	_transition_tween.tween_property(self, "global_position", target_pos, transition_time)
	_transition_tween.tween_property(self, "limit_left", new_l, transition_time)
	_transition_tween.tween_property(self, "limit_right", new_r, transition_time)
	_transition_tween.tween_property(self, "limit_top", new_t, transition_time)
	_transition_tween.tween_property(self, "limit_bottom", new_b, transition_time)
	
	_transition_tween.chain().tween_callback(func():
		is_transitioning = false
	)
