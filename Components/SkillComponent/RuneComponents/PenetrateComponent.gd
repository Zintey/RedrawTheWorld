class_name PenetrateComponent extends RuneComponent

func _ready():
    super()
    core.on_check_destroy.connect(_on_check_destroy)

func _on_check_destroy(request: Dictionary):
    var type = request.get("hit_type")
    if type == "body" or type == "area":
        request.can_destroy = false