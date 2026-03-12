extends DroneState
class_name DroneWarnMoveState

@export var warn_move_speed = 100.0

func enter() -> void:
	drone.animation_player.play("warn_move")
	drone.current_move_speed = warn_move_speed
	drone.sprite_2d.material.set_shader_parameter("outline_size", 1.0)

func exit() -> void:
	drone.sprite_2d.material.set_shader_parameter("outline_size", 0.0)

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if drone.check_lose_target():
		switched_to.emit(self, "safe_move")
		return
	
	if (drone.global_position - drone.target_body.global_position).length() > 200:
		drone.current_move_direction = (drone.target_body.global_position - drone.global_position).normalized()
	super.take_process(delta)