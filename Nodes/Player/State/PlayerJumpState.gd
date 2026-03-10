extends PlayerState
class_name PlayerJumpState

func enter() -> void:
	player.velocity.y = player.stats_component.jump_speed
	player.jump_request_timer.stop()
	player.coyote_timer.stop()
	player.stats_component.can_jump = false

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if player.velocity.y <= 0 : 
		switched_to.emit(self, "up_to_air")

	super.take_process(delta)
