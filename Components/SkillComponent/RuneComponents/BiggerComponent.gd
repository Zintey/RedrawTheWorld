class_name BiggerComponent extends RuneComponent

var bigger_multiple_base: float = 1.0
var target_multiple: float = 1.0
var bigger_timer: Timer

func _ready():
    super()
    bigger_timer = Timer.new()
    bigger_timer.wait_time = 0.01
    bigger_timer.one_shot = false
    add_child(bigger_timer)
    bigger_timer.timeout.connect(func (): core.scale *= target_multiple)
    bigger_timer.start()

# class_name BiggerComponent extends RuneComponent

# var bigger_multiple_base: float = 1.0
# var target_multiple: float = 1.0

# func _ready():
#     super()
#     # 0.5秒内平滑放大到目标倍数，或者你可以根据 lifetime 来设定时间
#     var tween = create_tween()
#     tween.tween_property(core, "scale", Vector2(target_multiple, target_multiple), 0.5)