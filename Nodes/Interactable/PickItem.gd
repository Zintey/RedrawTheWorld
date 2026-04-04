extends RigidBody2D
class_name PickItem

@export var item_data: ItemData
@export var sfx_data: AudioEvent

@onready var pick_area: Area2D = %PickArea

func _ready() -> void:
	pick_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if item_data.apply_effect(body):
		if sfx_data:
			AudioManager.play_sfx(sfx_data)
		queue_free()
