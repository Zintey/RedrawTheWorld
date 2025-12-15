extends StateBase 
class_name CannonState

@export var agent : Cannon

func enter() -> void:
	pass

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	
	if agent.target_body:
		agent.target_position = agent.target_body.global_position
	var target_rotation = (agent.target_position - agent.global_position).normalized().angle()
	if target_rotation > agent.global_rotation:
		agent.rotate_direction = agent.Direction.Right
	elif target_rotation == agent.global_rotation:
		agent.rotate_direction = agent.Direction.Stop
	else:
		agent.rotate_direction = agent.Direction.Left
	
	if (!agent.check_can_turn_left() and agent.rotate_direction == agent.Direction.Left) or (!agent.check_can_turn_right() and agent.rotate_direction == agent.Direction.Right):
		# agent.global_rotation = last_global_rotation
		agent.rotate_direction = agent.Direction.Stop
	
	# var last_global_rotation = agent.global_rotation
	if agent.on_follow:
		agent.global_rotation += agent.current_rotate_speed * agent.rotate_direction * delta
		if abs(agent.global_rotation - target_rotation) <= 0.01:
			agent.global_rotation = target_rotation
	
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	
	super.take_process(delta)
