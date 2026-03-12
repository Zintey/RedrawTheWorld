extends TrackedCutterStateBase
class_name TrackedCutterIdleState

func enter() -> void:
	cutter.animation_player.play("idle")
	cutter.current_speed = cutter.idle_speed
	cutter.sprite_2d.material.set_shader_parameter("outline_size", 0.0)

func exit() -> void:
	pass

func take_physics_process(delta: float) -> void:
	if !cutter.check_can_forward():
		switched_to.emit(self, "stop")
		if cutter.move_direction == cutter.Direction.Left:
			cutter.turn_right()
		else:
			cutter.turn_left()
	else:
		if !cutter.check_left_floor():
			cutter.turn_right()
		elif !cutter.check_right_floor():
			cutter.turn_left()
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if cutter.check_find_player():
		switched_to.emit(self, "follow")
		return

	super.take_process(delta)