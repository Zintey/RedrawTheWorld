extends PlayerState
class_name PlayerWalkState

func enter() -> void:
	player.animation_player.play("Kaer/walk")
	player.status_component.current_accelerate = player.status_component.floor_accelerate
	player.status_component.current_speed = player.status_component.walk_speed

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if abs(player.velocity.x) > player.status_component.walk_speed * 0.8:
		switched_to.emit(self, "run")
	
	if abs(player.velocity.x) == 0:
		switched_to.emit(self, "idle")
	 
	if player.velocity.y > 0:
		switched_to.emit(self, "fall")
	
	if player.velocity.y < -18:
		switched_to.emit(self, "up_to_air")
	
	if player.is_on_floor() and player.jump_request_timer.time_left > 0:
		switched_to.emit(self, "jump")
	super.take_process(delta)

