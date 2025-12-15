# extends PanelContainer
class_name RuneBriefUI
extends Control
@export var rune_data : RuneData
@onready var rune_name_label: Label = %RuneNameLabel
@onready var rune_description_label: Label = %RuneDescriptionLabel
@onready var stamina_cost_label: Label = %StaminaCostLabel

func init(_rune_data : RuneData) -> void:
	rune_data = _rune_data

func _process(delta: float) -> void:
	var current_position = Vector2(min(get_global_mouse_position().x, get_viewport_rect().size.x - size.x), 
	min(get_global_mouse_position().y, get_viewport_rect().size.y - size.y))
	global_position = current_position


func _ready():
	z_index = 10000
	if rune_data != null:
		rune_name_label.text = rune_data.display_name
		stamina_cost_label.text = "能量消耗：" + str(rune_data.stamina_cost)
		rune_description_label.text = rune_data.description
