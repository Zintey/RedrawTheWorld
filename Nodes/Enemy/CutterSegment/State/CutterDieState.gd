extends CutterState
class_name CutterDieState

func enter() -> void:
	cutter.velocity = Vector2.ZERO
	cutter.animation_player.play("die")
	cutter.sprite_2d.material.set_shader_parameter("hit", false)
	cutter.sprite_2d.material.set_shader_parameter("outline_size", 0.0)
	
	if is_instance_valid(cutter.hurt_box):
		cutter.hurt_box.queue_free()
	if is_instance_valid(cutter.hit_box): # 如果你用子节点找也可以，它在 Pivot 下面
		cutter.hit_box.queue_free()
		
	await cutter.animation_player.animation_finished
	cutter.queue_free()
