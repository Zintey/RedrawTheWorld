extends PlayerState
class_name PlayerLandState

const DUST_SCENE : PackedScene = preload("res://Nodes/Items/Dust/Dust.tscn")

func enter() -> void:
	player.last_on_floor_position = player.global_position
	player.animation_player.play("Kaer/land")

	player.skill_component.post_event("Landing", 0.1)
	player.stats_component.can_jump = true
	var dust :Node2D = DUST_SCENE.instantiate()
	dust.global_position = player.global_position
	dust.global_position.y += 27
	get_tree().current_scene.add_child(dust)

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if !player.animation_player.is_playing():
		switched_to.emit(self, "idle");
	super.take_process(delta)
