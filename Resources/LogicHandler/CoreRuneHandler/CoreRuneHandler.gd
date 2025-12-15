class_name CoreRuneHandler extends RefCounted

const CORE_RUNE_MAP : Dictionary = {
	"pulse_core_rune" : preload("res://Nodes/Runes/CoreRunes/Pulse/pulse_core_rune.tscn"),
	"arcane_orb_core_rune" : preload("res://Nodes/Runes/CoreRunes/ArcaneOrb/arcane_orb_core_rune.tscn"),
	"heal_orb_core_rune" : preload("uid://b257n0c5htrxo")
}

func get_core_rune_ins(core_rune_data : RuneData) -> Area2D:
	var rune_id = core_rune_data.rune_id
	if CORE_RUNE_MAP.has(rune_id):
		var core_rune_class : PackedScene = CORE_RUNE_MAP[rune_id]
		var core_rune = core_rune_class.instantiate()
		if core_rune:
			return core_rune
		else:
			push_error("实例化失败: 无法实例化核心符文 %s" % rune_id)
			return null
	push_error("Rune ID %s does not have a core_rune class." % rune_id)
	return null
