extends TrackedCutterStateBase
class_name TrackedCutterHitState

const Hit_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

func enter() -> void:
	cutter.current_speed *= -0.3
	cutter.animation_player.play("hit")
	cutter.sprite_2d.material.set_shader_parameter("hit", true)

	var hit_dust :Node2D = Hit_SCENE.instantiate()
	hit_dust.global_position = cutter.global_position
	get_tree().current_scene.add_child(hit_dust)
	# if is_instance_valid(agent.hurt_box):
		# agent.hurt_box.is_invincible = true
		
	super()

func exit() -> void:
	cutter.sprite_2d.material.set_shader_parameter("hit", false)
	# if is_instance_valid(agent.hurt_box):
		# agent.hurt_box.is_invincible = false
	super()

func take_process(delta : float) -> void:
	if !cutter.animation_player.is_playing():
		if !cutter.check_find_player():
			cutter.turn_back()
		switched_to.emit(self, "idle")
		return 
	super.take_process(delta)