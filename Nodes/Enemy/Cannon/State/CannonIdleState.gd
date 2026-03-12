extends CannonState
class_name CannonIdleState

func enter() -> void:
	cannon.animation_player.play("idle")
	cannon.sprite_2d.material.set_shader_parameter("outline_size", 0.0)

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	# 受击跳转已由基类接管，彻底删除 check_on_hit()
	if cannon.check_is_warning():
		switched_to.emit(self, "follow")
		return
	super.take_process(delta)