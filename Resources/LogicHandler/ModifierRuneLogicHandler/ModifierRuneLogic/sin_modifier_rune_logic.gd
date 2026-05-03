extends ModifierRuneLogicBase
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
    var amount = modifier_rune_data.parameters.get("amount", 0)
    var comp = core_rune.get_node_or_null("SinMovementComponent")
    if comp:
        comp.sin_amount += amount
    else:
        comp = SinMovementComponent.new()
        comp.name = "SinMovementComponent"
        comp.sin_amount = amount
        core_rune.add_child(comp)