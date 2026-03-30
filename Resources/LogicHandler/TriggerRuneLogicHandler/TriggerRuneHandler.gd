class_name TriggerRuneHandler extends RefCounted

const TRIGGER_LOGIC_MAP : Dictionary = {
	"key_lbt_hit_trigger_rune" : preload("res://Resources/LogicHandler/TriggerRuneLogicHandler/TriggerRuneLogic/key_lbt_hit_trigger_rune_logic.gd"),
	"key_rbt_hit_trigger_rune" : preload("res://Resources/LogicHandler/TriggerRuneLogicHandler/TriggerRuneLogic/key_rbt_hit_trigger_rune_logic.gd"),
	"key_space_hit_trigger_rune" : preload("res://Resources/LogicHandler/TriggerRuneLogicHandler/TriggerRuneLogic/key_space_hit_trigger_rune_logic.gd"),
	"on_hit_trigger_rune" : preload("uid://ko1aa7unvxcf"),
	"receive_signalA_trigger_rune" : preload("uid://c7mrs7n5cwc8y"),
}

# 【修改】：增加 blackboard 参数
func check_is_rune_triggered(rune_data : RuneData, blackboard : Dictionary, caster : Node2D) -> bool:
	var rune_id = rune_data.rune_id

	if TRIGGER_LOGIC_MAP.has(rune_id):
		var rune_logic_script = TRIGGER_LOGIC_MAP[rune_id]
		var rune_logic_instance = rune_logic_script.new()
		return rune_logic_instance.check_is_triggered(blackboard, caster)
	
	printerr("Rune ID %s does not have a corresponding trigger logic." % rune_id)
	return false