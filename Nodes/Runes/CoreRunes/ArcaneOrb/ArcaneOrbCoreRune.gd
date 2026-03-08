class_name ArcaneOrbCoreRune
extends CoreRuneBase

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var die = false


func _start_action():
	audio_stream_player.play()
	var timer = get_tree().create_timer(1.0, false)
	timer.timeout.connect(_finish_rune_action)
	EventBus.camera_shake.emit(Vector2(20.0,20.0),0.2)

	await animated_sprite_2d.animation_finished
	if !die:
		animated_sprite_2d.play("Idle")


func _finish_rune_action():
	try_emit_teleport_signal()
	die = true
	animated_sprite_2d.play("End")
	velocity = Vector2.ZERO
	await animated_sprite_2d.animation_finished
	super._finish_rune_action()


func _on_area_entered(area: Area2D) -> void:
	# print("area")
	if rebound_cnt <= 0:
		_finish_rune_action()
	else:
		pass
		# rebound_cnt -= 1


func _on_body_entered(body: Node2D) -> void:
	# print("body")
	if rebound_cnt <= 0:
		_finish_rune_action()
	else:
		pass
		# rebound_cnt -= 1



func _on_tracking_area_body_entered(body: Node2D) -> void:
	tracking_target = body
	# print("in ", body.name)

func _on_tracking_area_area_entered(area: Area2D) -> void:
	tracking_target = area.owner
	# print("in ", area.name)
