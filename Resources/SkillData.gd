@tool
class_name SkillData extends ItemData

enum SkillType {
	OR_TRIGGER,
	AND_TRIGGER
}

@export var skill_id : String = ""
@export var type : SkillType = SkillType.OR_TRIGGER

var skill_name :
	get():
		return item_name
var skill_description : String :
	get():
		return description + skill_description

var skill_icon : Texture2D :
	get():
		return icon

# 【新增】：技能的基础冷却时间（秒）
@export var base_cooldown : float = 0.5 

@export var trigger_rune_slot_count : int = 0 :
	set(val):
		trigger_rune_slot_count = max(1, val)
		trigger_rune_list.resize(trigger_rune_slot_count)
@export var trigger_rune_list : Array[RuneData] = []

@export var core_rune_slot_count : int = 0:
	set(val):
		core_rune_slot_count = max(0, val)
		core_rune_list.resize(core_rune_slot_count)
@export var core_rune_list : Array[RuneData] = []

@export var modifier_rune_slot_count : int = 0:
	set(val):
		modifier_rune_slot_count = max(0, val)
		modifier_rune_list.resize(modifier_rune_slot_count)
@export var modifier_rune_list : Array[RuneData] = []


func apply_effect(player: Node2D) -> bool:
	var inventory = player.inventory_component
	if inventory and inventory.add_skill(self):
		return true
	return false