extends StaticBody2D
class_name Door

@export var switch : Switch
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	if switch:
		switch.switch_to_open.connect(on_open_door)

func on_open_door():
	animation_player.play("open")
	audio_stream_player.play()
