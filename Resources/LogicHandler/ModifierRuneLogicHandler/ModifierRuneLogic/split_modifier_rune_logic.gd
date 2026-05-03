extends ModifierRuneLogicBase
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
    if core_rune.has_meta("is_split") and core_rune.get_meta("is_split"): return
    
    var comp = core_rune.get_node_or_null("SplitComponent")
    if comp:
        comp.split_cnt *= 2
    else:
        comp = SplitComponent.new()
        comp.name = "SplitComponent"
        comp.split_cnt = 2 
        core_rune.add_child(comp)