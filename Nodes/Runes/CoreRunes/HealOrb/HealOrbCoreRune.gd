# class_name 
extends CoreRuneBase
class_name HealOrbCoreRune
@onready var animation_player: AnimationPlayer = %AnimationPlayer

const Heal_FX = preload("uid://02hh3jlh76mc")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _start_action():
	audio_stream_player.play()
	await animation_player.animation_finished
	animation_player.play("idle")

	await animation_player.animation_finished
	_finish_rune_action()


func _finish_rune_action():
	try_emit_teleport_signal()
	animation_player.play("end")
	await animation_player.animation_finished
	super._finish_rune_action()


func _on_area_entered(area: Area2D) -> void:
	var body = area.owner
	if body as Player:
		body  = body as Player
		body.health_component.recover_hp(2)
		var heal_fx : Node2D = Heal_FX.instantiate()
		heal_fx.global_position = body.global_position
		get_tree().current_scene.add_child(heal_fx)
	elif body.has_node("HealthComponent"):
		var health_component = body.get_node("HealthComponent") as HealthComponent
		health_component.recover_hp(2)
		var heal_fx : Node2D = Heal_FX.instantiate()
		heal_fx.global_position = body.global_position
		get_tree().current_scene.add_child(heal_fx)



func _on_tracking_area_body_entered(body: Node2D) -> void:
	tracking_target = body

func _on_tracking_area_area_entered(area: Area2D) -> void:
	tracking_target = area.owner
