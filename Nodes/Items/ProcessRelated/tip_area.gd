extends Area2D

@onready var tip_label: Label = %TipLabel
# Called when the node enters the scene tree for the first time.
var visible_tween : Tween

func _enter_tree() -> void:
	visible = false

func _ready() -> void:
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(tip_label, "position:y", 10, 1.0).as_relative()
	tween.tween_property(tip_label, "position:y", -10, 1.0).as_relative()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# func _on_body_entered(body: Node2D) -> void:
# 	if body as Player:
# 		visible = true
# 	if visible_tween:
# 		visible_tween.kill()
# 	visible_tween = get_tree().create_tween()
# 	visible_tween.tween_property(tip_label, "modulate", Color(1.0,1.0,1.0,1.0), 0.5).from(Color(1.0,1.0,1.0,0.0))
		

# func _on_body_exited(body: Node2D) -> void:
# 	if body as Player:
# 		if visible_tween:
# 			visible_tween.kill()
# 		visible_tween = get_tree().create_tween()
# 		visible_tween.tween_property(tip_label, "modulate", Color(1.0,1.0,1.0,0.0), 0.5)
# 		await visible_tween.finished
# 		self.visible = false



func _on_area_exited(area: Area2D) -> void:
	if visible_tween:
		visible_tween.kill()
	visible_tween = get_tree().create_tween()
	visible_tween.tween_property(tip_label, "modulate", Color(1.0,1.0,1.0,0.0), 0.5)
	await visible_tween.finished
	self.visible = false

func _on_area_entered(area: Area2D) -> void:
	visible = true
	if visible_tween:
		visible_tween.kill()
	visible_tween = get_tree().create_tween()
	visible_tween.tween_property(tip_label, "modulate", Color(1.0,1.0,1.0,1.0), 0.5).from(Color(1.0,1.0,1.0,0.0))
