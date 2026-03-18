extends CannonState
class_name CannonHitState

const Hit_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

func enter() -> void:
	cannon.animation_player.play("hit")
	cannon.sprite_2d.material.set_shader_parameter("hit", true)
	cannon.on_follow = false
	
	var hit_dust :Node2D = Hit_SCENE.instantiate()
	hit_dust.global_position = cannon.global_position
	get_tree().current_scene.add_child(hit_dust)
	# if is_instance_valid(agent.hurt_box):
		# agent.hurt_box.is_invincible = true
	super()

func exit() -> void:
	cannon.sprite_2d.material.set_shader_parameter("hit", false)
	# if is_instance_valid(agent.hurt_box):
		# agent.hurt_box.is_invincible = false
	super()

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	# 去除了 check_is_die() 的逻辑，死亡已由基类接管
	if !cannon.animation_player.is_playing():
		switched_to.emit(self, "follow")
		return 
	super.take_process(delta)