extends CannonState
class_name CannonDieState

func enter() -> void:
	cannon.animation_player.play("die")
	cannon.on_follow = false
	cannon.sprite_2d.material.set_shader_parameter("hit", false)
	cannon.sprite_2d.material.set_shader_parameter("outline_size", 0.0)
	
	# 安全释放受击框，防止死亡过程中还被打中
	if is_instance_valid(cannon.hurt_box):
		cannon.hurt_box.queue_free()
		
	# 【修复】：等待死亡动画播完再释放节点
	await cannon.animation_player.animation_finished
	cannon.queue_free()

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