class_name PulseCoreRune extends CoreRuneBase
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var pulse_sfx : AudioEvent
# @onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer


func _start_action():
	can_gravity = false
	can_swirl = false

	var timer = get_tree().create_timer(life_time * life_time_mul, false)
	timer.timeout.connect(_finish_rune_action)
	EventBus.camera_shake.emit(Vector2(2.0,2.0),0.01)
	# audio_stream_player.play()
	AudioManager.play_sfx(pulse_sfx)
	scale.x *= speed_mul
	
	if caster as Player:
		caster = caster as Player
		# 修改点：把 status_component 改成 stats_component
		caster.stats_component.add_force(
		-Vector2(velocity_direction.x * 22, velocity_direction.y * 20) * speed_mul)

		caster.stats_component.enable_jump = false
		caster.stats_component.enable_move = false
	
	

# func _process(delta: float) -> void:
	# if caster.has_node("StatusComponent"):
		# caster.status_component.enable_move = false
		# caster.status_component.enable_jump = false

func _finish_rune_action():	
	try_emit_teleport_signal()
	animated_sprite_2d.play("End")
	animation_player.play_backwards("End")
	caster.stats_component.enable_move = true
	caster.stats_component.enable_jump = true
	await animation_player.animation_finished
	super()



func _on_tracking_area_body_entered(body: Node2D) -> void:
	tracking_target = body
	# print("in ", body.name)

func _on_tracking_area_area_entered(area: Area2D) -> void:
	tracking_target = area.owner
	# print("in ", area.name)
