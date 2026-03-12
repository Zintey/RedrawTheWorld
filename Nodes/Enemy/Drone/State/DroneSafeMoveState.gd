extends DroneState
class_name DroneSafeMoveState

var timer : Timer

@export var safe_move_speed : float = 50.0
var origin_position : Vector2

func check_in_patrol_range() -> bool:
	return (drone.global_position - origin_position).length() <= drone.patrol_range

func enter() -> void:
	origin_position = drone.global_position
	drone.animation_player.play("safe_move")
	drone.current_move_speed = safe_move_speed

	drone.current_move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	
func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if drone.check_is_warn():
		switched_to.emit(self, "warn_move")
		return
	if !check_in_patrol_range():
		drone.current_move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	super.take_process(delta)