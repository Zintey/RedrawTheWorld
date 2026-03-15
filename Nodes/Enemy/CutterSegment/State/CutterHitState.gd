extends CutterState
class_name CutterHitState

const Hit_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

func enter() -> void:
	cutter.velocity = Vector2.ZERO
	cutter.animation_player.play("hit")
	# cutter.sprite_2d.material.set_shader_parameter("hit", true)
	
	if is_instance_valid(cutter.hurt_box):
		cutter.hurt_box.is_invincible = true
	
	var hit_dust: Node2D = Hit_SCENE.instantiate()
	hit_dust.global_position = cutter.global_position
	get_tree().current_scene.add_child(hit_dust)
	
	super()

func exit() -> void:
	# cutter.sprite_2d.material.set_shader_parameter("hit", false)
	if is_instance_valid(cutter.hurt_box):
		cutter.hurt_box.is_invincible = false
	super()

func take_process(delta: float) -> void:
	if not cutter.animation_player.is_playing():
		switched_to.emit(self, "idle")
