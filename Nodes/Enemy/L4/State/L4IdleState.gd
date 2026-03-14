extends L4State
class_name L4IdleState

var turn_timer: Timer

func enter() -> void:
	l4.animation_player.play("idle")
	l4.velocity.x = l4.idle_speed * l4.move_direction
	
	turn_timer = Timer.new()
	turn_timer.wait_time = randf_range(2.0, 4.0)
	turn_timer.autostart = true
	turn_timer.timeout.connect(func(): l4.turn_back())
	add_child(turn_timer)

func exit() -> void:
	if turn_timer: turn_timer.queue_free()

func take_physics_process(delta: float) -> void:
	# 索敌与状态分配
	if is_instance_valid(l4.target_body):
		var dist = l4.global_position.distance_to(l4.target_body.global_position)
		if dist < l4.safe_distance:
			switched_to.emit(self, "attack2") # 玩家太近，冲刺拉开
		else:
			switched_to.emit(self, "attack1") # 距离安全，原地射击
		return

	# 悬崖与墙壁巡逻
	if l4.is_on_wall():
		l4.turn_back()
	elif l4.move_direction == l4.Direction.Left and not l4.check_left_floor():
		l4.turn_right()
	elif l4.move_direction == l4.Direction.Right and not l4.check_right_floor():
		l4.turn_left()

	l4.velocity.x = l4.idle_speed * l4.move_direction
	super.take_physics_process(delta)