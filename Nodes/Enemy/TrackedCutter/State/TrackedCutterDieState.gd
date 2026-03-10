extends TrackedCutterStateBase
class_name TrackedCutterDieState

func enter() -> void:
	agent.die_signal.emit()
	agent.animation_player.play("die")
	agent.sprite_2d.material.set_shader_parameter("hit", false)
	agent.sprite_2d.material.set_shader_parameter("outline_size", 0.0)
	agent.current_speed = 0.0
	agent.hurt_box.queue_free()
	agent.hit_box.queue_free()
	agent.queue_free()
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
