extends Node2D
class_name EnemyComing

signal start_spawn

func spawning() -> void:
	start_spawn.emit()