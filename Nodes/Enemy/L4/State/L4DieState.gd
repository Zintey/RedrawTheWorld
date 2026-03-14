extends L4State
class_name L4DieState

func enter() -> void:
	l4.velocity.x = 0.0
	l4.animation_player.play("die")
	l4.sprite_2d.material.set_shader_parameter("hit", false)
	l4.sprite_2d.material.set_shader_parameter("outline_size", 0.0)
	
	if is_instance_valid(l4.hurt_box):
		l4.hurt_box.queue_free()
	if is_instance_valid(l4.hit_box):
		l4.hit_box.queue_free()
		
	await l4.animation_player.animation_finished
	l4.queue_free()

func exit() -> void:
	pass

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)
