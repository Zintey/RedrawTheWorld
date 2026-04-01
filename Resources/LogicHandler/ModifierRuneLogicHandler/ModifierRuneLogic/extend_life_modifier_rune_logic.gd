extends ModifierRuneLogicBase

	
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
	core_rune.life_time_mul += modifier_rune_data.parameters.get("extenging_amount", 0.0)
	

