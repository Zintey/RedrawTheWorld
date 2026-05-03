class_name SkillCircleHandler extends Node

var core_rune_handler: CoreRuneHandler
var skill_data: SkillData
var caster: PhysicsBody2D

func _init(_skill_data: SkillData, _caster: PhysicsBody2D) -> void:
    skill_data = _skill_data
    caster = _caster
    core_rune_handler = CoreRuneHandler.new()

func _ready() -> void:
    var main_scene = get_tree().current_scene
    
    for core_rune_data in skill_data.core_rune_list:
        if core_rune_data == null:
            continue
            
        var core_rune: CoreRuneBase = core_rune_handler.get_core_rune_ins(core_rune_data)
        if core_rune:
            main_scene.add_child(core_rune)
            
            var start_pos = caster.global_position
            if caster.has_node("RuneEmitter") and caster.rune_emitter.emitter_point:
                start_pos = caster.rune_emitter.emitter_point.global_position
            core_rune.global_position = start_pos
                
            core_rune.velocity_direction = (core_rune.get_global_mouse_position() - start_pos).normalized()
            
            if caster.get("stats_component") and caster.stats_component.get("fire_facing_left"):
                if core_rune.velocity_direction.x > 0:
                    core_rune.velocity_direction.x *= -1
                
            core_rune.init(core_rune_data, caster, skill_data.modifier_rune_list)
        else:
            printerr("Failed to instantiate core rune for skill %s" % skill_data.skill_id)
            
    queue_free()