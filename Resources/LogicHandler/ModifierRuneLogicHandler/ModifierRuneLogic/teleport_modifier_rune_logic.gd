extends ModifierRuneLogicBase

	
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
    if modifier_rune_data.parameters.has("teleport"):
        core_rune.is_teleport = modifier_rune_data.parameters["teleport"]
	

