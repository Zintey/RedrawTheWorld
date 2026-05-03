extends ModifierRuneLogicBase

func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune: CoreRuneBase) -> void:
    var comp = core_rune.get_node_or_null("GravityComponent")
    if comp:
        comp.gravity += 980.0 
    else:
        comp = GravityComponent.new()
        comp.name = "GravityComponent"
        comp.gravity = 980.0
        core_rune.add_child(comp)