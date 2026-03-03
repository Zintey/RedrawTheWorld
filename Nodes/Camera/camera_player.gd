extends Camera2D

@export var target_node: Node2D # 在编辑器里把 Player 拖进来
@export var follow_speed: float = 5.0
@export var transition_time: float = 0.5

var is_transitioning: bool = false
var _current_tween: Tween

func _ready():
	# return
	limit_smoothed = true # 开启平滑限制转换
	position_smoothing_enabled = false # 我们自己控制平滑，或者开启这个也行

func _physics_process(delta: float) -> void:
	# return
	if is_transitioning or not target_node:
		return
	
	# 平滑跟随玩家
	global_position = global_position.lerp(target_node.global_position, follow_speed * delta)

func transition_to_room(boundary: RoomBase.Boundary, room_global_pos: Vector2):
	# return
	is_transitioning = true
	
	if _current_tween:
		_current_tween.kill()
	
	# 1. 计算目标房间的绝对边界
	var new_l = int(room_global_pos.x + boundary.left)
	var new_r = int(room_global_pos.x + boundary.right)
	var new_t = int(room_global_pos.y + boundary.top)
	var new_b = int(room_global_pos.y + boundary.bottom)
	
	# 2. 计算摄像机视口的合法目标位置（贴边逻辑）
	var view_size = get_viewport_rect().size / zoom
	var half_view = view_size / 2.0
	
	var target_x = clamp(target_node.global_position.x, new_l + half_view.x, new_r - half_view.x)
	var target_y = clamp(target_node.global_position.y, new_t + half_view.y, new_b - half_view.y)
	var target_pos = Vector2(target_x, target_y)

	# 3. 创建 Tween 并手动对五个属性做同步动画
	_current_tween = create_tween()
	_current_tween.set_parallel(true) # 开启并行模式，让位置和限制同时变
	_current_tween.set_ease(Tween.EASE_OUT)
	_current_tween.set_trans(Tween.TRANS_CUBIC)
	
	# 动画 A: 移动摄像机坐标
	_current_tween.tween_property(self, "global_position", target_pos, transition_time)
	
	# 动画 B: 手动平滑四个边界
	# 这能解决你说的“抖动”问题，因为上下左右的限制线是“慢慢滑”到新位置的
	_current_tween.tween_property(self, "limit_left", new_l, transition_time)
	_current_tween.tween_property(self, "limit_right", new_r, transition_time)
	_current_tween.tween_property(self, "limit_top", new_t, transition_time)
	_current_tween.tween_property(self, "limit_bottom", new_b, transition_time)
	
	# 4. 动画完成后的回调
	_current_tween.chain().tween_callback(func():
		is_transitioning = false
		print("手动过渡完成，当前边界: ", new_l, new_r, new_t, new_b)
	)
