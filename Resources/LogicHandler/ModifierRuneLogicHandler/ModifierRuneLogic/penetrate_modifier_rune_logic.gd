extends ModifierRuneLogicBase

func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune: CoreRuneBase) -> void:
    if not core_rune.has_node("PenetrateComponent"):
        var comp = PenetrateComponent.new()
        comp.name = "PenetrateComponent"
        core_rune.add_child(comp)