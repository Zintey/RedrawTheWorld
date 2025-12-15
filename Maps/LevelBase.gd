extends Node2D
class_name LevelBase

@onready var camera_2d: Camera2D = %Camera2D
@onready var tile_map_layer: TileMapLayer = %TileMapLayer

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	var used : Rect2i = tile_map_layer.get_used_rect()
	var tile_size : = tile_map_layer.tile_set.tile_size
	if (audio_stream_player) :
		audio_stream_player.play()
	camera_2d.limit_top = (used.position.y + 1) * tile_size.y
	camera_2d.limit_bottom = (used.end.y - 1) * tile_size.y
	camera_2d.limit_left = (used.position.x + 1) * tile_size.x
	camera_2d.limit_right = (used.end.x - 1)  * tile_size.x 
