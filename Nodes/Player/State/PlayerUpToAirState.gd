extends PlayerState 
class_name PlayerUpToAirState

func enter() -> void:
	player.animation_player.play("Kaer/jump")
	player.stats_component.current_accelerate = player.stats_component.air_accelerate
	# print("velocity y :", player.velocity.y)

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	player.skill_component.post_event("hanging", 0.1)
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if player.velocity.y > 0 and !player.is_on_floor():
		switched_to.emit(self, "fall")
	if player.is_on_floor():
		switched_to.emit(self, "idle")
	super.take_process(delta)
