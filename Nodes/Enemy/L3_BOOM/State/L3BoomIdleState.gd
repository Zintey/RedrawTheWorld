extends L3BoomState
class_name L3BoomIdleState

var origin_position : Vector2
var current_move_direction : Vector2
var change_dir_timer : Timer

func enter() -> void:
	boom.animation_player.play("idle")
	
	# 记录初始出生点作为游走圆心
	if origin_position == Vector2.ZERO:
		origin_position = boom.global_position
		
	pick_new_direction()
	
	# 设置一个计时器，每隔 1.5 ~ 2.5 秒换个方向飞
	change_dir_timer = Timer.new()
	change_dir_timer.wait_time = randf_range(1.5, 2.5)
	change_dir_timer.autostart = true
	change_dir_timer.timeout.connect(pick_new_direction)
	add_child(change_dir_timer)

func exit() -> void:
	if change_dir_timer:
		change_dir_timer.queue_free()

func pick_new_direction() -> void:
	current_move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if change_dir_timer:
		change_dir_timer.wait_time = randf_range(1.5, 2.5)

func take_physics_process(delta: float) -> void:
	# 如果发现玩家，立刻切换到警告追踪状态
	if boom.target_body:
		switched_to.emit(self, "warning")
		return

	# 游走边界限制：如果离出生点太远，就强制往出生点飞
	if boom.global_position.distance_to(origin_position) > boom.wander_radius:
		current_move_direction = (origin_position - boom.global_position).normalized()

	boom.velocity = current_move_direction * boom.idle_speed
	
	# 翻转朝向
	if current_move_direction.x > 0:
		boom.turn_right()
	elif current_move_direction.x < 0:
		boom.turn_left()

	super.take_physics_process(delta)
