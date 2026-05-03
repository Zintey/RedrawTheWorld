class_name HealOrbCoreRune extends CoreRuneBase

@onready var animation_player: AnimationPlayer = %AnimationPlayer
const Heal_FX = preload("uid://02hh3jlh76mc")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var die = false

func _start_action():
    audio_stream_player.play()
    var timer = get_tree().create_timer(life_time * life_time_mul, false)
    timer.timeout.connect(_finish_rune_action)
    await animation_player.animation_finished
    if !die:
        animation_player.play("idle")

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
    
    animation_player.play("end")
    await animation_player.animation_finished
    on_destroyed.emit()
    queue_free()

func _on_area_entered(area: Area2D) -> void:
    var body = area.owner
    var healed = false
    
    if body as Player:
        body = body as Player
        body.health_component.recover_hp(2)
        _spawn_heal_fx(body)
        healed = true
    elif body.has_node("HealthComponent"):
        var health_component = body.get_node("HealthComponent") as HealthComponent
        health_component.recover_hp(2)
        _spawn_heal_fx(body)
        healed = true
        
    if not healed:
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

func _spawn_heal_fx(target: Node2D):
    var heal_fx: Node2D = Heal_FX.instantiate()
    heal_fx.global_position = target.global_position
    get_tree().current_scene.add_child(heal_fx)