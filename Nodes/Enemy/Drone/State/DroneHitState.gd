extends DroneState
class_name DroneHitState


const Hit_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

func enter() -> void:
	# agent.status_component.decrease_hp(35)
	agent.animation_player.play("hit")
	agent.sprite_2d.material.set_shader_parameter("hit", true)
	agent.current_move_speed = 0.0
	var hit_dust :Node2D = Hit_SCENE.instantiate()
	hit_dust.global_position = agent.global_position
	get_tree().current_scene.add_child(hit_dust)

	super()

func exit() -> void:
	agent.sprite_2d.material.set_shader_parameter("hit", false)
	agent.status_component.on_hit = false
	super()

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:

	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if agent.check_is_die():
		switched_to.emit(self, "die")
		return 
	if !agent.animation_player.is_playing():
		switched_to.emit(self, "warn_move")
		return 
	super.take_process(delta)
