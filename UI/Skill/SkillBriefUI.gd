# extends PanelContainer
class_name SkillBriefUI
extends Control
@export var skill_data : SkillData
@onready var skill_name_label: Label = %SkillNameLabel
@onready var skill_description_label: Label = %SkillDescriptionLabel

func init(_skill_data : SkillData) -> void:
	skill_data = _skill_data

func _process(delta: float) -> void:
	var current_position = Vector2(min(get_global_mouse_position().x, get_viewport_rect().size.x - size.x), 
	min(get_global_mouse_position().y, get_viewport_rect().size.y - size.y))
	global_position = current_position


func _ready():
	z_index = 10000
	if skill_data != null:
		skill_name_label.text = skill_data.skill_name
		skill_description_label.text = skill_data.skill_description
