extends CannonState
class_name CannonFollowState

func enter() -> void:
	agent.animation_player.play("idle")
	agent.current_rotate_speed = agent.rotate_speed
	agent.sprite_2d.material.set_shader_parameter("outline_size", 2.0)
	agent.on_follow = true

func exit() -> void:
	agent.on_follow = false

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if agent.check_on_hit():
		switched_to.emit(self, "hit")
		return 

	if agent.check_turn_to_target():
		if randf_range(0.0, 1.0) <= 0.2:
			switched_to.emit(self, "attack1")
			return
		else:
			switched_to.emit(self, "attack2")
			return

	if agent.check_lose_warning():
		switched_to.emit(self, "idle")
		return
	

	super.take_process(delta)
