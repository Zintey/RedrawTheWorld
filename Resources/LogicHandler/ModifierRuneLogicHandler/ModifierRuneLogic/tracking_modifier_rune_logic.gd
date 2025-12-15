extends ModifierRuneLogicBase

	
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
	if modifier_rune_data.parameters.has("tracking"):
		core_rune.tracking_strength += modifier_rune_data.parameters["tracking"]
	else:
		printerr("tracking modifier logic param lost")
	

