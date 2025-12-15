extends StateBase
class_name TrackedCutterStateBase

@export var agent : TrackedCutter

func enter() -> void:
	pass

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	if not agent.is_on_floor():
		agent.velocity += agent.get_gravity() * delta
	
	if agent.move_direction:
		agent.velocity.x = agent.move_direction * agent.current_speed
	else:
		agent.velocity.x = agent.move_toward(agent.velocity.x, 0, agent.current_speed)

	agent.velocity += agent.status_component.get_force()
	agent.move_and_slide()
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	
	

	super.take_process(delta)
