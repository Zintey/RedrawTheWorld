extends TrackedCutterStateBase
class_name TrackedCutterDieState

func enter() -> void:
	cutter.animation_player.play("die")
	cutter.sprite_2d.material.set_shader_parameter("hit", false)
	cutter.sprite_2d.material.set_shader_parameter("outline_size", 0.0)
	cutter.current_speed = 0.0
	cutter.hurt_box.queue_free()
	cutter.hit_box.queue_free()
	
	await cutter.animation_player.animation_finished
	cutter.queue_free()

func exit() -> void:
	pass