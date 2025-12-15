@tool
extends PanelContainer
class_name SkillTemplateUI

const RUNESLOTUI : PackedScene = preload("res://UI/Rune/rune_slot_ui.tscn")

var is_drag_item : bool = false
# var drag_offset_position : Vector2

@export var skill_data : SkillData

@onready var trigger_rune_v_box: HBoxContainer = %TriggerRuneVBox
@onready var core_rune_v_box: HBoxContainer = %CoreRuneVBox
@onready var modifier_rune_v_box: HBoxContainer = %ModifierRuneVBox
@onready var skill_template_name: Label = %SkillTemplateName

func init(_skill_data : SkillData, _is_drag_item : bool = false) -> void:
	skill_data = _skill_data
	is_drag_item = _is_drag_item
	# drag_offset_position = _drag_offset_position

func _process(delta: float) -> void:
	if is_drag_item:
		global_position = get_global_mouse_position() - Vector2(size.x / 2, 0)


func update_skill_data(new_skill_data : SkillData) -> void:
	skill_data = new_skill_data
	update_trigger_rune_v_box(skill_data.trigger_rune_list)
	update_core_rune_v_box(skill_data.core_rune_list)
	update_modifier_rune_v_box(skill_data.modifier_rune_list)
	skill_template_name.text = skill_data.skill_name

func _ready() -> void:
	if skill_data:
		update_skill_data(skill_data)
	if is_drag_item:
		z_index = 10000

func update_trigger_rune_v_box(trigger_rune_list : Array[RuneData]) -> void:
	for rune_slot in trigger_rune_v_box.get_children():
		rune_slot.queue_free()

	var cnt : int = 0
	for trigger_rune in trigger_rune_list:
		var slot : RuneSlotUI = RUNESLOTUI.instantiate()
		slot.init(trigger_rune, cnt, RuneData.RuneType.TRIGGER)
		slot.rune_data_changed.connect(func(new_rune_data : RuneData, slot_id : int) -> void:
			trigger_rune_list[slot_id] = new_rune_data
			print("Trigger rune data in slot %d changed." % slot_id)
		)
		cnt += 1
		trigger_rune_v_box.add_child(slot)
		# var slot_rune_data : RuneData = null
		# if trigger_rune:
		# 	slot_rune_data = trigger_rune
		# slot.set_rune_data(slot_rune_data)

func update_core_rune_v_box(core_rune_list : Array[RuneData]) -> void:
	for rune_slot in core_rune_v_box.get_children():
		rune_slot.queue_free()

	var cnt : int = 0
	for core_rune in core_rune_list:
		var slot : RuneSlotUI = RUNESLOTUI.instantiate()
		slot.init(core_rune, cnt, RuneData.RuneType.CORE)
		slot.rune_data_changed.connect(func(new_rune_data : RuneData, slot_id : int) -> void:
			core_rune_list[slot_id] = new_rune_data
			print("Core rune data in slot %d changed." % slot_id)
		)
		cnt += 1
		core_rune_v_box.add_child(slot)


func update_modifier_rune_v_box(modifier_rune_list : Array[RuneData]) -> void:
	for rune_slot in modifier_rune_v_box.get_children():
		rune_slot.queue_free()

	#var cnt : int = 0
	#for modifier_rune in modifier_rune_list:
	for i in range(modifier_rune_list.size()):
		var modifier_rune = modifier_rune_list[i]
		var slot : RuneSlotUI = RUNESLOTUI.instantiate()
		slot.init(modifier_rune, i, RuneData.RuneType.MODIFIER)
		slot.rune_data_changed.connect(func(new_rune_data : RuneData, slot_id : int) -> void:
			modifier_rune_list[slot_id] = new_rune_data
			print("Modifire rune data in slot %d changed." % slot_id)
		)
		modifier_rune_v_box.add_child(slot)
	
