extends ModifierRuneLogicBase
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
    if modifier_rune_data.parameters.has("rebound"):
        var amount = modifier_rune_data.parameters["rebound"]
        var comp = core_rune.get_node_or_null("BounceComponent")
        if comp: 
            comp.max_bounces += amount
        else:
            comp = BounceComponent.new()
            comp.name = "BounceComponent"
            comp.max_bounces = amount
            core_rune.add_child(comp)