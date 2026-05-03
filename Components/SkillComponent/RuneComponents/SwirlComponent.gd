class_name SwirlComponent extends RuneComponent

var swirl_speed_multiplier: float = 1.5
var is_returning: bool = false
const CATCH_DISTANCE: float = 30.0

func _ready():
    super()
    core.on_tick.connect(_on_tick)
    core.on_life_timeout.connect(_on_life_timeout)
    core.on_check_destroy.connect(_on_check_destroy)

func _on_check_destroy(request: Dictionary):
    if is_returning:
        request.can_destroy = false

func _on_life_timeout():
    if not is_returning:
        is_returning = true

func _on_tick(_delta: float):
    if not is_returning: return

    var last_pos = core.caster.global_position if is_instance_valid(core.caster) else core.global_position
    var dir_to_target = last_pos - core.global_position
    
    if dir_to_target.length() <= CATCH_DISTANCE:
        core.on_destroyed.emit()
        core.queue_free()
        return
        
    core.velocity = dir_to_target.normalized() * (core.speed * core.speed_mul * swirl_speed_multiplier)