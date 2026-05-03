class_name GravityComponent extends RuneComponent

var gravity: float = 980.0

func _ready():
    super()
    core.on_tick.connect(_on_tick)

func _on_tick(delta: float):
    core.velocity.y += gravity * delta