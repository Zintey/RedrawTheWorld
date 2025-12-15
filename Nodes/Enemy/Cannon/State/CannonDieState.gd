extends CannonState
class_name CannonDieState

func enter() -> void:
	agent.animation_player.play("die")
	agent.on_follow = false
	agent.sprite_2d.material.set_shader_parameter("hit", false)
	agent.sprite_2d.material.set_shader_parameter("outline_size", 0.0)
	
	if agent.hurt_box:
		agent.hurt_box.queue_free()
	if agent.hit_box:
		agent.hit_box.queue_free()
func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:

	super.take_physics_process(delta)

func take_process(delta : float) -> void:

	super.take_process(delta)
