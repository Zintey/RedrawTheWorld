extends DroneState
class_name  DroneSafeMoveState

var timer : Timer

@export var safe_move_speed : float = 50.0
var origin_position : Vector2

func check_in_patrol_range() -> bool:
	return (agent.global_position - origin_position).length() <= agent.patrol_range

func enter() -> void:
	origin_position = agent.global_position
	agent.animation_player.play("safe_move")
	agent.current_move_speed = safe_move_speed

	agent.current_move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	

func exit() -> void:
	pass

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
	if agent.check_is_warn():
		switched_to.emit(self, "warn_move")
		return
	if !check_in_patrol_range():
		agent.current_move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	super.take_process(delta)

