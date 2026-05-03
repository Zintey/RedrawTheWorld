class_name TeleportComponent extends RuneComponent

var teleport_point: Node2D = null

func try_teleport():
    if teleport_point == null:
        EventBus.player_teleport_request.emit(core.global_position)
    else:
        EventBus.player_teleport_request.emit(teleport_point.global_position)