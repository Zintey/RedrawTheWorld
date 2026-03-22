class_name FloatingText extends Marker2D

@onready var label: Label = $Label

func start(text_content: String, color: Color) -> void:
	label.text = text_content
	label.modulate = color
	
	# 果汁感：向上飘移的同时变透明
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 40, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)