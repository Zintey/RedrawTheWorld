class_name PulseCoreRune extends CoreRuneBase

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@export var pulse_sfx : AudioEvent

func _start_action():
    var grav = get_node_or_null("GravityComponent")
    if grav: grav.set_process(false); grav.gravity = 0
    var swirl = get_node_or_null("SwirlComponent")
    if swirl: swirl.set_process(false)

    var timer = get_tree().create_timer(life_time * life_time_mul, false)
    timer.timeout.connect(_finish_rune_action)
    EventBus.camera_shake.emit(Vector2(2.0,2.0),0.01)
    AudioManager.play_sfx(pulse_sfx)
    scale.x *= speed_mul
    
    if caster as Player:
        caster = caster as Player
        caster.stats_component.add_force(
            -Vector2(velocity_direction.x * 22, velocity_direction.y * 20) * speed_mul)
        caster.stats_component.enable_jump = false
        caster.stats_component.enable_move = false

func _finish_rune_action():	
    on_life_timeout.emit()
    var request = {"can_destroy": true, "hit_type": "timeout"}
    on_check_destroy.emit(request)
    if not request.can_destroy: return

    var tp_comp = get_node_or_null("TeleportComponent")
    if tp_comp: tp_comp.try_teleport()
    
    animated_sprite_2d.play("End")
    animation_player.play_backwards("End")
    
    if is_instance_valid(caster):
        caster.stats_component.enable_move = true
        caster.stats_component.enable_jump = true
        
    await animation_player.animation_finished
    on_destroyed.emit()
    queue_free()