extends PropState
class_name PropIdleState

func enter() -> void:
	prop.animation_player.play("idle")