@tool
extends PanelContainer
class_name SkillListUI

const SKILLSLOTUI = preload("res://UI/Skill/skill_slot_ui.tscn")
@export var skill_list : Array[SkillData] = []
@onready var skill_slot_hbox: HBoxContainer = %SkillSlotHBox
@export_multiline var list_name : String
@onready var list_name_label: Label = %ListNameLabel

func set_skill_list(_skill_list) -> void:
	skill_list = _skill_list
	
	for child in skill_slot_hbox.get_children():
		child.queue_free()
	
	for i in range(skill_list.size()):
		var skill_data : SkillData = skill_list[i]
		var skill_slot : SkillSlotUI = SKILLSLOTUI.instantiate()
		skill_slot.init(skill_data, i)
		skill_slot.skill_data_changed.connect(func(new_skill_data : SkillData, slot_id : int) -> void:
			skill_list[slot_id] = new_skill_data
			# print("Skill data in slot %d changed." % slot_id)
		)
		skill_slot_hbox.add_child(skill_slot)

func _ready() -> void:
	pass
	# if Engine.is_editor_hint():
	# 	set_equipped_skill_list(equipped_skill_list)
	if skill_list:
		set_skill_list(skill_list)
	list_name_label.text = list_name
	
func _process(delta: float) -> void:
	pass
