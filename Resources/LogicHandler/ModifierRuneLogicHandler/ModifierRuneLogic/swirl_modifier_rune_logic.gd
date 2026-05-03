extends ModifierRuneLogicBase
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
    if not core_rune.has_node("SwirlComponent"):
        var comp = SwirlComponent.new()
        comp.name = "SwirlComponent"
        core_rune.add_child(comp)