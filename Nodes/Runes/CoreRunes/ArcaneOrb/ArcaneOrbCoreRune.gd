
class_name ArcaneOrbCoreRune extends CoreRuneBase

@export var orb_fire_sfx: AudioEvent
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
var die = false

func _start_action():
    AudioManager.play_sfx(orb_fire_sfx)
    var timer = get_tree().create_timer(life_time * life_time_mul, false)
    timer.timeout.connect(_finish_rune_action)
    EventBus.camera_shake.emit(Vector2(20.0,20.0),0.2)

    await animated_sprite_2d.animation_finished
    if !die:
        animated_sprite_2d.play("Idle")

func _finish_rune_action():
    if die: return
    
    on_life_timeout.emit()
    var request = {"can_destroy": true, "hit_type": "timeout"}
    on_check_destroy.emit(request)
    
    if not request.can_destroy: return
        
    die = true
    set_physics_process(false)
    velocity = Vector2.ZERO
    
    var tp_comp = get_node_or_null("TeleportComponent")
    if tp_comp: tp_comp.try_teleport()
    
    animated_sprite_2d.play("End")
    await animated_sprite_2d.animation_finished
    on_destroyed.emit()
    queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area is HurtBox:
        on_hit.emit(area)
        var request = {"can_destroy": true, "hit_type": "area", "hit_target": area}
        on_check_destroy.emit(request)
        if request.can_destroy:
            _finish_rune_action()

func _on_body_entered(body: Node2D) -> void:
    on_hit.emit(body) 
    var request = {"can_destroy": true, "hit_type": "body", "hit_target": body}
    on_check_destroy.emit(request)
    if request.can_destroy:
        _finish_rune_action()