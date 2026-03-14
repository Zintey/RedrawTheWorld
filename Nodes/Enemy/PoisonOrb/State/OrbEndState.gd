extends OrbState
class_name OrbEndState

func enter() -> void:
	orb.velocity = Vector2.ZERO
	orb.rotation = 0.0
	orb.animation_player.play("end")
	
	if is_instance_valid(orb.hit_box):
		orb.hit_box.queue_free()
		
	await orb.animation_player.animation_finished
	orb.queue_free()