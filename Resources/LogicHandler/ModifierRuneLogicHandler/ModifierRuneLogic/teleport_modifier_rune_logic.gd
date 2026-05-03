extends ModifierRuneLogicBase
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
    if modifier_rune_data.parameters.has("teleport") and modifier_rune_data.parameters["teleport"]:
        if not core_rune.has_node("TeleportComponent"):
            var comp = TeleportComponent.new()
            comp.name = "TeleportComponent"
            core_rune.add_child(comp)