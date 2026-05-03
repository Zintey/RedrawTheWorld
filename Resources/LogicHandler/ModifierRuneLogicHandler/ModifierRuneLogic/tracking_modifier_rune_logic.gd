extends ModifierRuneLogicBase
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
    if modifier_rune_data.parameters.has("tracking"):
        var strength = modifier_rune_data.parameters["tracking"]
        var comp = core_rune.get_node_or_null("TrackingComponent")
        if comp:
            comp.tracking_strength += strength
        else:
            comp = TrackingComponent.new()
            comp.name = "TrackingComponent"
            comp.tracking_strength = strength
            core_rune.add_child(comp)