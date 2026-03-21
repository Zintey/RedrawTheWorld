extends Camera2D

@export_group("Follow & Transition")
@export var target_node: Node2D # 目标玩家
@export var follow_speed: float = 5.0 # 跟随速度

@export_group("Advanced Shake")
@export var noise_frequency: float = 10.0 
@export var shake_decay_curve: Curve

# ==============================
# 内部变量
# ==============================
var is_transitioning: bool = false
var _transition_tween: Tween

# 【核心新增】：镜头状态栈与动态属性兜底
var _camera_area_stack: Array[CameraArea] = []
@onready var default_zoom: Vector2 = zoom
@onready var default_follow_speed: float = follow_speed
var current_follow_speed: float = 5.0

# 震动相关核心
var _noise = FastNoiseLite.new()
var _active_shakes: Array[ShakeInstance] = []
var _noise_timer: float = 0.0

class ShakeInstance:
	var strength: Vector2   
	var duration: float     
	var time_left: float    
	var noise_y_offset: float 
	
	func _init(s: Vector2, d: float):
		strength = s
		duration = d
		time_left = d
		noise_y_offset = randf_range(0, 1000.0)

# ==============================
# 生命周期与核心逻辑
# ==============================
func _ready():
	limit_smoothed = true 
	position_smoothing_enabled = false
	current_follow_speed = follow_speed # 初始化动态速度
	
	_noise.seed = randi()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = 0.5 
	
	if has_node("/root/EventBus"):
		var eb = get_node("/root/EventBus")
		if eb.has_signal("camera_shake"):
			eb.camera_shake.connect(_on_camera_shake)
		# 【新增】：监听区域变化
		if eb.has_signal("camera_area_entered"):
			eb.camera_area_entered.connect(_on_camera_area_entered)
			eb.camera_area_exited.connect(_on_camera_area_exited)
	else:
		printerr("Camera2D Error: Autoload singleton 'EventBus' not found.")


func _physics_process(delta: float) -> void:
	_process_shake_stack(delta)
	
	if is_transitioning or not target_node:
		return
	
	# 【修改】：使用动态的 current_follow_speed 而不是写死的常量
	global_position = global_position.lerp(target_node.global_position, current_follow_speed * delta)

# ==============================
# 【核心新增】：摄像机区域栈管理
# ==============================
func _on_camera_area_entered(area: CameraArea):
	if not _camera_area_stack.has(area):
		_camera_area_stack.append(area)
		_apply_top_camera_area()

func _on_camera_area_exited(area: CameraArea):
	if _camera_area_stack.has(area):
		_camera_area_stack.erase(area)
		_apply_top_camera_area()

func _apply_top_camera_area():
	if _transition_tween:
		_transition_tween.kill()

	_transition_tween = create_tween()
	_transition_tween.set_parallel(true)
	_transition_tween.set_ease(Tween.EASE_OUT)
	_transition_tween.set_trans(Tween.TRANS_CUBIC)

	is_transitioning = true
	
	var target_l: float
	var target_r: float
	var target_t: float
	var target_b: float
	var t_zoom: Vector2
	var t_speed: float
	var t_time: float

	# 兜底：如果退出了所有区域，解除一切束缚，重置参数
	if _camera_area_stack.is_empty():
		target_l = -10000000
		target_r = 10000000
		target_t = -10000000
		target_b = 10000000
		t_zoom = default_zoom
		t_speed = default_follow_speed
		t_time = 0.5 
	else:
		# 永远只听栈顶（最后进入）的区域指挥
		var top_area = _camera_area_stack.back()
		# 清理一下可能已经失效的节点
		if not is_instance_valid(top_area):
			_camera_area_stack.pop_back()
			_apply_top_camera_area()
			return
			
		target_l = top_area.boundary.left
		target_r = top_area.boundary.right
		target_t = top_area.boundary.top
		target_b = top_area.boundary.bottom
		t_zoom = top_area.target_zoom
		t_speed = top_area.follow_speed
		t_time = top_area.transition_time

	# 安全计算过渡目标点（防止区域比视口还小导致的画面乱飞）
	var view_size = get_viewport_rect().size / t_zoom
	var half_view = view_size / 2.0
	var min_x = min(target_l + half_view.x, target_r - half_view.x)
	var max_x = max(target_l + half_view.x, target_r - half_view.x)
	var min_y = min(target_t + half_view.y, target_b - half_view.y)
	var max_y = max(target_t + half_view.y, target_b - half_view.y)
	
	var target_x = clamp(target_node.global_position.x, min_x, max_x)
	var target_y = clamp(target_node.global_position.y, min_y, max_y)
	
	# 执行全面的平滑过渡动画
	_transition_tween.tween_property(self, "global_position", Vector2(target_x, target_y), t_time)
	_transition_tween.tween_property(self, "limit_left", int(target_l), t_time)
	_transition_tween.tween_property(self, "limit_right", int(target_r), t_time)
	_transition_tween.tween_property(self, "limit_top", int(target_t), t_time)
	_transition_tween.tween_property(self, "limit_bottom", int(target_b), t_time)
	_transition_tween.tween_property(self, "zoom", t_zoom, t_time)
	_transition_tween.tween_property(self, "current_follow_speed", t_speed, t_time)

	_transition_tween.chain().tween_callback(func():
		is_transitioning = false
	)

# ==============================
# 震动系统核心实现 (保持原有逻辑)
# ==============================
func _on_camera_shake(strength: Vector2, duration: float):
	var new_shake = ShakeInstance.new(strength, duration)
	_active_shakes.append(new_shake)

func _process_shake_stack(delta: float):
	if _active_shakes.is_empty():
		if offset != Vector2.ZERO:
			offset = Vector2.ZERO
		return

	_noise_timer += delta * noise_frequency
	var total_offset = Vector2.ZERO
	
	for i in range(_active_shakes.size() - 1, -1, -1):
		var shake = _active_shakes[i]
		shake.time_left -= delta
		if shake.time_left <= 0:
			_active_shakes.remove_at(i)
			continue
		
		var progress = 1.0 - (shake.time_left / shake.duration)
		var decay_factor = shake_decay_curve.sample(progress) if shake_decay_curve else (1.0 - progress)
		var noise_raw_x = _noise.get_noise_2d(_noise_timer, shake.noise_y_offset)
		var noise_raw_y = _noise.get_noise_2d(shake.noise_y_offset, _noise_timer) 
		
		var current_shake_offset = Vector2(
			noise_raw_x * shake.strength.x * decay_factor,
			noise_raw_y * shake.strength.y * decay_factor
		)
		total_offset += current_shake_offset
	offset = total_offset
