extends StateBase 
class_name DroneState

@export var agent : Drone

func enter() -> void:
	pass

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	

	# if !agent.check_can_move():
		# agent.current_move_direction = -agent.current_move_direction
	var hitinfo: KinematicCollision2D = agent.move_and_collide(agent.current_move_speed * agent.current_move_direction * delta,true)
	if hitinfo:
		# agent.current_move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
		agent.current_move_direction += (agent.global_position - hitinfo.get_position()).normalized()
		agent.current_move_direction = agent.current_move_direction.normalized()

	agent.velocity = agent.current_move_speed * agent.current_move_direction
	
	agent.center_point.scale.x = 1.0 if agent.current_move_direction.x > 0 else -1.0
	
	if agent.enable_gravity:
		agent.velocity += agent.get_gravity() * 15 * delta
	agent.move_and_slide()
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	
	super.take_process(delta)

