extends L4State
class_name L4HitState

const Hit_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

func enter() -> void:
	l4.velocity.x = 0.0
	l4.animation_player.play("hit")
	l4.sprite_2d.material.set_shader_parameter("hit", true)
	
	if is_instance_valid(l4.hurt_box):
		l4.hurt_box.is_invincible = true
	
	var hit_dust: Node2D = Hit_SCENE.instantiate()
	hit_dust.global_position = l4.global_position
	get_tree().current_scene.add_child(hit_dust)
	
	super()

func exit() -> void:
	l4.sprite_2d.material.set_shader_parameter("hit", false)
	if is_instance_valid(l4.hurt_box):
		l4.hurt_box.is_invincible = false
	super()

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta: float) -> void:
	if not l4.animation_player.is_playing():
		switched_to.emit(self, "idle")