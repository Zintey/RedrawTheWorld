class_name SkillCircleHandler extends Node

var core_rune_handler : CoreRuneHandler

var skill_data : SkillData
var caster : PhysicsBody2D


func _init(_skill_data: SkillData, _caster : PhysicsBody2D) -> void:
	skill_data = _skill_data
	caster = _caster
	
	core_rune_handler = CoreRuneHandler.new()

func _ready() -> void:
	for core_rune_data in skill_data.core_rune_list:
		if core_rune_data == null:
			continue
		var core_rune : CoreRuneBase = core_rune_handler.get_core_rune_ins(core_rune_data)
		if core_rune:
			add_child(core_rune)
			core_rune.init(core_rune_data, caster, skill_data.modifier_rune_list)
			
		else:
			printerr("Failed to instantiate core rune for skill %s" % skill_data.skill_id)
	# var core_rune_data : RuneData = skill_data.core_rune_data
	# var core_rune = core_rune_handler.get_core_rune_ins(core_rune_data)
	# if core_rune:
	# 	add_child(core_rune)
	# 	core_rune.init(core_rune_data, caster, skill_data.modifier_rune_list)
		
	# else:
	# 	printerr("Failed to instantiate core rune for skill %s" % skill_data.skill_id)
