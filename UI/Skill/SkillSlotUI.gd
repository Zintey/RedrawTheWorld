@tool
extends PanelContainer
class_name SkillSlotUI

var empty_skill_data : SkillData = SkillData.new()

@export var slot_id : int = -1
signal skill_data_changed(skill_data : SkillData, slot_id : int)
@export var skill_data : SkillData:
	set (value):
		if value == null:
			skill_data = null
			if skill_template_ui != null:
				skill_template_ui.update_skill_data(empty_skill_data)
		skill_data = value
		if skill_template_ui != null and skill_data != null:
			skill_template_ui.update_skill_data(skill_data)
		skill_data_changed.emit(skill_data, slot_id)

@onready var skill_template_ui: SkillTemplateUI = %SkillTemplateUI
@onready var button: Button = $MarginContainer/Button


func init(_skill_data : SkillData, _slot_id : int) -> void:
	skill_data = _skill_data
	slot_id = _slot_id

func set_skill_data(_skill_data : SkillData) -> void:
	skill_data = _skill_data

func _ready() -> void:
	if skill_data:
		skill_template_ui.update_skill_data(skill_data)




func _on_button_button_up() -> void:
	if skill_data == null:
		return
	EventBus.skill_drag_ended.emit(skill_data, self)



func _on_button_button_down() -> void:
	if skill_data == null:
		return
	EventBus.skill_drag_started.emit(skill_data, self)
	
	skill_template_ui.update_skill_data(empty_skill_data)


func _on_button_mouse_entered() -> void:
	if skill_data == null:
		return
	UIManager.skill_brief_requested.emit(skill_data)



func _on_button_mouse_exited() -> void:
	if skill_data == null:
		return
	UIManager.skill_brief_closed.emit()
