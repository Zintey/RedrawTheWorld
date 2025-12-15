extends Control
class_name InventoryUI

var inventory_component : InventoryComponent = null

@onready var runes_inventory_ui : RunesInventoryUI = %RunesInventoryUI
@onready var equipped_skill_list_ui : SkillListUI = %EquippedSkillListUI
@onready var allskill_list_ui: SkillListUI = %ALLSkillListUI

func init(_inventory_component : InventoryComponent) -> void:
	inventory_component = _inventory_component

func _ready() -> void:
	inventory_component.data_changed.connect(update_inventory_ui)
	update_inventory_ui()

func update_inventory_ui():
	runes_inventory_ui.set_runes_inventory(inventory_component.all_runes)
	equipped_skill_list_ui.set_skill_list(inventory_component.equipped_skills)
	allskill_list_ui.set_skill_list(inventory_component.all_skills)
