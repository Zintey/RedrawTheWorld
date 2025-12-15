# 速度增益符文
extends ModifierRuneLogicBase

func apply_modifier_to_core_rune(modifier_rune_data : RuneData, core_rune : CoreRuneBase) -> void:
	if modifier_rune_data.parameters.has("speed_mul"):
		# print("speed_up_modifire_rune_logic.gd: Applying speed multiplier %f to core rune." % modifire_rune_data.parameters["speed_mul"])
		core_rune.speed_mul *= modifier_rune_data.parameters["speed_mul"]
		# if core_rune.effect_list.has("speed_up_rune"):
		# 	core_rune.effect_list["speed_up_rune"] = 1.0
		# core_rune.effect_list["speed_up_rune"] *= modifire_rune_data.parameters["speed_mul"]
	else:
		printerr("speed_up_modifire_rune_logic.gd: Missing 'speed_mul' parameter in ", modifier_rune_data.rune_id)
	
	
 