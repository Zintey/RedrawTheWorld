extends ModifierRuneLogicBase
func apply_modifier_to_core_rune(modifier_rune_data : RuneData, core_rune : CoreRuneBase) -> void:
    if modifier_rune_data.parameters.has("speed_mul"):
        core_rune.speed_mul *= modifier_rune_data.parameters["speed_mul"]