class_name SinMovementComponent extends RuneComponent

var sin_amount: float = 0.0
var sin_moving_time: float = 0.0
var sin_moving_dir: Vector2

func _ready():
    super()
    sin_moving_dir = core.velocity.rotated(PI / 2).normalized()
    core.on_tick.connect(_on_tick)

func _on_tick(delta: float):
    var final_velocity = core.velocity
    final_velocity += sin_amount * sin_moving_dir * sin(sin_moving_time * 30)
    core.velocity = final_velocity.normalized() * core.velocity.length()
    sin_moving_time += delta