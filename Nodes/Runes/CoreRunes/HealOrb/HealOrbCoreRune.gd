extends CoreRuneBase
class_name HealOrbCoreRune

@onready var animation_player: AnimationPlayer = %AnimationPlayer
const Heal_FX = preload("uid://02hh3jlh76mc")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var die = false 

func _start_action():
    audio_stream_player.play()
    await animation_player.animation_finished
    
    if !die:
        animation_player.play("idle")

    await animation_player.animation_finished
    _finish_rune_action()

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
    animation_player.play("end")
    await animation_player.animation_finished
    super._finish_rune_action() 

func _on_area_entered(area: Area2D) -> void:
    # 治疗球本就不会因为碰到人而销毁，所以不需要加 if need_penetrate: return
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
    if is_returning: return 
    tracking_target = body

func _on_tracking_area_area_entered(area: Area2D) -> void:
    if is_returning: return 
    tracking_target = area.owner