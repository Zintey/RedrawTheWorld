extends ModifierRuneLogicBase

	
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
	core_rune.absorb_stamina += modifier_rune_data.parameters.get("absorb_amount", 0)
	

