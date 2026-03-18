extends DroneState
class_name DroneHitState

const Hit_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

func enter() -> void:
	drone.animation_player.play("hit")
	drone.sprite_2d.material.set_shader_parameter("hit", true)
	drone.current_move_speed = 0.0
	
	var hit_dust :Node2D = Hit_SCENE.instantiate()
	hit_dust.global_position = drone.global_position
	get_tree().current_scene.add_child(hit_dust)
	# if is_instance_valid(agent.hurt_box):
		# agent.hurt_box.is_invincible = true
		
	super()

func exit() -> void:
	drone.sprite_2d.material.set_shader_parameter("hit", false)
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
	# 死亡跳转已经由 EnemyBase 接管
	if !drone.animation_player.is_playing():
		switched_to.emit(self, "warn_move")
		return 
	super.take_process(delta)
