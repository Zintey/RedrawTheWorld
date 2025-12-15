extends Control
class_name RuneItemUI


@export var rune_data : RuneData
@onready var rune_icon: TextureRect = %RuneIcon

func init(_rune_data : RuneData) -> void:
	rune_data = _rune_data

func _process(delta: float) -> void:
	global_position = get_global_mouse_position() - Vector2(rune_icon.size.x / 2, rune_icon.size.y / 2)


func _ready():
	z_index = 10000
	if rune_data != null:
		rune_icon.texture = rune_data.icon
