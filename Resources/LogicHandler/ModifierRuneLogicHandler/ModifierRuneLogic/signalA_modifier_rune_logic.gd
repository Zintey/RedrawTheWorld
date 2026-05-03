extends ModifierRuneLogicBase
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
    EventBus.emit_rune_signalA.emit()