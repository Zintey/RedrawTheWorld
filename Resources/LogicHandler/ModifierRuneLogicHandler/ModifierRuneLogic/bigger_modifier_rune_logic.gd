extends ModifierRuneLogicBase

	
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
	core_rune.bigger_multiple += core_rune.bigger_multiple_base * modifier_rune_data.parameters.get("bigger_amount", 0.0)
	

