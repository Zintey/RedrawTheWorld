extends ModifierRuneLogicBase

	
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
	core_rune.sin_moving_amount += modifier_rune_data.parameters.get("amount", 0)
	

