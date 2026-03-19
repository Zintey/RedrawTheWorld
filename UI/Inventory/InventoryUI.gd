extends Control
class_name InventoryUI

var inventory_component : InventoryComponent = null

@onready var runes_inventory_ui : RunesInventoryUI = %RunesInventoryUI

# 【核心修改】：干掉旧列表，绑定新的左侧面板
@onready var left_skill_panel : LeftSkillPanel = %LeftSkillPanel

func init(_inventory_component : InventoryComponent) -> void:
	inventory_component = _inventory_component

func _ready() -> void:
	inventory_component.data_changed.connect(update_inventory_ui)
	update_inventory_ui()

func update_inventory_ui():
	if inventory_component == null: return
	runes_inventory_ui.set_runes_inventory(inventory_component.all_runes)
	
	# 【核心修改】：把真实数据喂给 UI 中枢
	if is_instance_valid(left_skill_panel):
		left_skill_panel.init_skills(inventory_component.equipped_skills)
