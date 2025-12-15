@tool
class_name SkillData extends Resource

enum SkillType {
	OR_TRIGGER,
	AND_TRIGGER
}

@export var skill_id : String = ""
@export var type : SkillType = SkillType.OR_TRIGGER
@export var skill_name : String = ""
@export_multiline var skill_description : String = ""
@export var skill_icon : Texture2D

@export var trigger_rune_slot_count : int = 0 :
	set(val):
		trigger_rune_slot_count = max(1, val)
		trigger_rune_list.resize(trigger_rune_slot_count)
@export var trigger_rune_list : Array[RuneData] = []
# @export var core_rune_data : RuneData
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
