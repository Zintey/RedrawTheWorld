extends Node2D

@export_file("*map.tscn") var switch_scene : String
@export var enter_point_name : String

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body as Player:
		SceneManager.switch_to(switch_scene, enter_point_name)

