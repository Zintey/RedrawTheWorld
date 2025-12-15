extends TrackedCutterStateBase
class_name TrackedCutterIdleState

func enter() -> void:
	agent.animation_player.play("idle")
	agent.current_speed = agent.idle_speed
	agent.sprite_2d.material.set_shader_parameter("outline_size", 0.0)

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	if !agent.check_can_forward():
		if agent.move_direction == agent.Direction.Left:
			agent.turn_right()
		else:
			agent.turn_left()
	else:
		if !agent.check_left_floor():
			agent.turn_right()
		elif !agent.check_right_floor():
			agent.turn_left()
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if agent.check_on_hit():
		switched_to.emit(self, "hit")
		return
	if agent.check_find_player():
		switched_to.emit(self, "follow")
		return

	super.take_process(delta)

