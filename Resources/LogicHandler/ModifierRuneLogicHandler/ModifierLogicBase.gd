extends RefCounted
class_name ModifierRuneLogicBase

	
func apply_modifier_to_core_rune(modifier_rune_data: RuneData, core_rune : CoreRuneBase) -> void:
	printerr("辅助符文： ", self.get_class()," 需要重写apply_modifire_to_core_rune方法")
	
