class_name ArcaneOrbCoreRune
extends CoreRuneBase

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var die = false

func _start_action():
    audio_stream_player.play()
    var timer = get_tree().create_timer(1.5, false)
    timer.timeout.connect(_finish_rune_action)
    EventBus.camera_shake.emit(Vector2(20.0,20.0),0.2)

    await animated_sprite_2d.animation_finished
    if !die:
        animated_sprite_2d.play("Idle")

func _finish_rune_action():
    if can_swirl and need_swirl and not is_returning:
        super._finish_rune_action()
        return 
        
    if is_returning:
        var dir_to_target = last_caster_pos - global_position
        if dir_to_target.length() > CATCH_DISTANCE:
            return 

    if die: 
        return
    die = true
    
    set_physics_process(false) 
    velocity = Vector2.ZERO
    
    try_emit_teleport_signal()
    animated_sprite_2d.play("End")
    
    await animated_sprite_2d.animation_finished
    super._finish_rune_action()

func _on_area_entered(area: Area2D) -> void:
    # 【穿透核心】：处于回旋状态，或者带有穿透符文时，直接免疫销毁，切豆腐一样穿过去！
    if is_returning or need_penetrate:
        return 
        
    if rebound_cnt <= 0:
        _finish_rune_action()

func _on_body_entered(body: Node2D) -> void:
    # 【穿透核心】：处于回旋状态，或者带有穿透符文时，直接免疫销毁，切豆腐一样穿过去！
    if is_returning or need_penetrate:
        return 
        
    if rebound_cnt <= 0:
        _finish_rune_action()

func _on_tracking_area_body_entered(body: Node2D) -> void:
    if is_returning: return 
    tracking_target = body

func _on_tracking_area_area_entered(area: Area2D) -> void:
    if is_returning: return 
    tracking_target = area.owner