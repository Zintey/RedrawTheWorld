extends Camera2D

var camera_shake_strength : Vector2 = Vector2.ZERO


func _ready() -> void:
	EventBus.camera_shake.connect(on_camera_shake)


func on_camera_shake(strength : Vector2, during : float) -> void:
	# print("yew")
	camera_shake_strength += strength
	get_tree().create_timer(during).timeout.connect(func()->void:
		camera_shake_strength -= strength
		)
	

func _process(delta: float) -> void:
	offset = randf() * camera_shake_strength
