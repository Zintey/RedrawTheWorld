extends ModifierRuneLogicBase

func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
    var amount = modifier_rune_data.parameters.get("absorb_amount", 0)
    var comp = core_rune.get_node_or_null("AbsorbComponent")
    if comp:
        comp.absorb_amount += amount
    else:
        comp = AbsorbComponent.new()
        comp.name = "AbsorbComponent"
        comp.absorb_amount = amount
        core_rune.add_child(comp)