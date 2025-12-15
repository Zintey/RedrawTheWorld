extends TrackedCutterStateBase
class_name TrackedCutterHitState

const Hit_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

func enter() -> void:
	agent.current_speed *= -0.3
	agent.animation_player.play("hit")
	agent.sprite_2d.material.set_shader_parameter("hit", true)

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
		if !agent.check_find_player():
			agent.turn_back()
		switched_to.emit(self, "idle")
		return 
	super.take_process(delta)
