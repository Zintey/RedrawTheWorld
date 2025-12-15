extends PlayerState
class_name PlayerIdleState

func enter() -> void:
	player.animation_player.play("Kaer/idle")

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if abs(player.velocity.x) > abs(player.status_component.get_force().x * 1.5):
		switched_to.emit(self, "run")
	
	if player.velocity.y < -18:
		switched_to.emit(self, "up_to_air")
	
	if player.velocity.y > 0:
		switched_to.emit(self, "fall")
	
	if player.is_on_floor() and player.jump_request_timer.time_left > 0:
		switched_to.emit(self, "jump")

	super.take_process(delta)
