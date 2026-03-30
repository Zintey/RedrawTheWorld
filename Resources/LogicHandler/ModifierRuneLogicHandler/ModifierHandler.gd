class_name ModifierRuneHandler extends RefCounted


const MODIFIER_LOGIC_MAP : Dictionary = {
	"speed_up_modifier_rune" : preload("res://Resources/LogicHandler/ModifierRuneLogicHandler/ModifierRuneLogic/speed_up_modifier_rune_logic.gd"),
	"snip_modifier_rune" : preload("res://Resources/LogicHandler/ModifierRuneLogicHandler/ModifierRuneLogic/snip_modifier_rune_logic.gd"),
	"tracking_modifier_rune" : preload("uid://cg1xsa3y27gth"),
	"rebound_modifier_rune" : preload("uid://cpaar1x8oacnx"),
	"teleport_modifier_rune" : preload("uid://bloomrubxbfhc"),
	"gravity_modifier_rune" : preload("uid://dwlpiog6ppvgf"),
	"split_modifier_rune" : preload("uid://cyu7f5mlhvknb"),
	"swirl_modifier_rune" : preload("uid://c5gaixmdqp6gm"),
	"penetrate_modifier_rune" : preload("uid://cxwim0182c2h5"),
	"signalA_modifier_rune" : preload("uid://bff4i1ckocp0q"),
}



func apply_modifier(modifier_rune_data : RuneData, core_rune : CoreRuneBase) -> void:
	var rune_id = modifier_rune_data.rune_id

	if MODIFIER_LOGIC_MAP.has(rune_id):
		var rune_logic_script = MODIFIER_LOGIC_MAP[rune_id]
		var rune_logic_instance : ModifierRuneLogicBase = rune_logic_script.new()
		rune_logic_instance.apply_modifier_to_core_rune(modifier_rune_data,core_rune)
		# print(modifier_rune_data.display_name, " had done")
		return
		
	printerr("Rune ID %s does not have a corresponding modifier logic." % rune_id)
