extends RigidBody2D

@export var coin_data: CoinData

@onready var pick_area: Area2D = %PickArea

func _ready() -> void:
	pick_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if coin_data.apply_effect(body):
		queue_free()

