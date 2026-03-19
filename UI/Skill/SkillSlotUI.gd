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

func init(_skill_data : SkillData, _slot_id : int) -> void:
	skill_data = _skill_data
	slot_id = _slot_id

func set_skill_data(_skill_data : SkillData) -> void:
	skill_data = _skill_data

func _ready() -> void:
	if skill_data:
		skill_template_ui.update_skill_data(skill_data)
		
	# 【关键修复】：强制绑定根节点的悬停信号
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

# ==================== 技能原生拖拽 ====================
func _get_drag_data(at_position: Vector2) -> Variant:
	if skill_data == null: return null
	
	var preview = preload("res://UI/Skill/SkillTemplate/skill_template_ui.tscn").instantiate()
	preview.init(skill_data, true)
	var control = Control.new()
	control.add_child(preview)
	preview.position = -preview.size / 2
	set_drag_preview(control)
	
	skill_template_ui.modulate.a = 0.3
	UIManager.skill_brief_closed.emit()
	
	return {"source_skill_slot": self, "skill_data": skill_data}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("skill_data"):
		self.modulate = Color(1.5, 1.5, 1.5, 1.0) 
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	self.modulate = Color(1, 1, 1, 1)
	var source_slot = data["source_skill_slot"]
	var drag_skill = data["skill_data"]
	
	var temp_data = self.skill_data
	self.skill_data = drag_skill
	source_slot.skill_data = temp_data

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		self.modulate = Color(1, 1, 1, 1)
		if is_instance_valid(skill_template_ui):
			skill_template_ui.modulate.a = 1.0

# ==================== 悬停 ====================
func _on_mouse_entered() -> void:
	if skill_data == null: return
	UIManager.skill_brief_requested.emit(skill_data)

func _on_mouse_exited() -> void:
	if skill_data == null: return
	UIManager.skill_brief_closed.emit()