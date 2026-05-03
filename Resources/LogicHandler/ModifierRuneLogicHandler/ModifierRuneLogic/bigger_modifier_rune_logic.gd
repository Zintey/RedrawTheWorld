extends ModifierRuneLogicBase
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune: CoreRuneBase) -> void:
    var amount = modifier_rune_data.parameters.get("bigger_amount", 0.0)
    var comp = core_rune.get_node_or_null("BiggerComponent")
    if comp:
        comp.target_multiple += comp.bigger_multiple_base * amount
    else:
        comp = BiggerComponent.new()
        comp.name = "BiggerComponent"
        comp.target_multiple = 1.0 + (comp.bigger_multiple_base * amount)
        core_rune.add_child(comp)