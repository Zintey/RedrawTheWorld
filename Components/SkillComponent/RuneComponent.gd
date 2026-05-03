class_name RuneComponent extends Node2D

var core: CoreRuneBase

func _ready():
	core = get_parent() as CoreRuneBase