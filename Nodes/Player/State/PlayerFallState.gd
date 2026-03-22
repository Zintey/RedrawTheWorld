extends PlayerState
class_name PlayerFallState

func enter() -> void:
	player.animation_player.play("Kaer/falling")
	player.coyote_timer.start()
	pass

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	player.velocity.y = clamp(player.velocity.y, 0, 500) 
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if player.global_position.y >= 500000.0:
		player.global_position = player.last_on_floor_position
		switched_to.emit(self,"teleport")
		return

	if player.is_on_floor():
		switched_to.emit(self, "land")
	
	if player.velocity.y < 0:
		switched_to.emit(self, "up_to_air")

	if player.coyote_timer.time_left > 0 and player.stats_component.can_jump and player.jump_request_timer.time_left > 0:
		switched_to.emit(self, "jump")
	super.take_process(delta)
