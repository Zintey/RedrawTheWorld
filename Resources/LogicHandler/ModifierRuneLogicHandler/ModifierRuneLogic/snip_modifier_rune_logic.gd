extends ModifierRuneLogicBase


func apply_modifier_to_core_rune(modifier_rune_data : RuneData, core_rune : CoreRuneBase) -> void:
	core_rune.velocity_direction =(core_rune.get_global_mouse_position() - core_rune.caster.global_position).normalized()
