extends DroneState
class_name  DroneWarnMoveState

@export var warn_move_speed = 100.0

func enter() -> void:
	agent.animation_player.play("warn_move")
	agent.current_move_speed = warn_move_speed
	agent.sprite_2d.material.set_shader_parameter("outline_size", 1.0)


func exit() -> void:
	agent.sprite_2d.material.set_shader_parameter("outline_size", 0.0)


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
	if agent.check_lose_target():
		switched_to.emit(self, "safe_move")
		return
	
	if (agent.global_position - agent.target_body.global_position).length() > 200:
		agent.current_move_direction = (agent.target_body.global_position - agent.global_position).normalized()
	super.take_process(delta)
