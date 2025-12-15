class_name TriggerRuneHandler extends RefCounted


const TRIGGER_LOGIC_MAP : Dictionary = {
	"key_lbt_hit_trigger_rune" : preload("res://Resources/LogicHandler/TriggerRuneLogicHandler/TriggerRuneLogic/key_lbt_hit_trigger_rune_logic.gd"),
	"key_rbt_hit_trigger_rune" : preload("res://Resources/LogicHandler/TriggerRuneLogicHandler/TriggerRuneLogic/key_rbt_hit_trigger_rune_logic.gd"),
	"key_space_hit_trigger_rune" : preload("res://Resources/LogicHandler/TriggerRuneLogicHandler/TriggerRuneLogic/key_space_hit_trigger_rune_logic.gd"),
	
}



func check_is_rune_triggered(rune_data : RuneData, caster : Node2D) -> bool:
	var rune_id = rune_data.rune_id

	if TRIGGER_LOGIC_MAP.has(rune_id):
		var rune_logic_script = TRIGGER_LOGIC_MAP[rune_id]
		var rune_logic_instance = rune_logic_script.new()
		return rune_logic_instance.check_is_triggered(caster)
	
	printerr("Rune ID %s does not have a corresponding trigger logic." % rune_id)
	return false
