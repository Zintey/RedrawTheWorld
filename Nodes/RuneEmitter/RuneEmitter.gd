extends Node2D
class_name RuneEmitter
@onready var emitter_point: Node2D = %EmitterPoint
@onready var sprites: Node2D = %Sprites
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var rune_sprite: Sprite2D = %RuneSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprites.rotation = (global_position - get_global_mouse_position()).angle()
	# print(sprites.rotation_degrees)

func fire(skill_data : SkillData) -> void:
	if skill_data and skill_data.core_rune_list[0]:
		rune_sprite.texture = skill_data.core_rune_list[0].icon
	animation_player.play("fire")
	await animation_player.animation_finished
	rune_sprite.texture = null
