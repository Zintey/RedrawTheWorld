extends PlayerState
class_name PlayerDieState

func enter() -> void:
	player.animation_player.play("Kaer/die")
	player.rune_emitter.visible = false
	await player.animation_player.animation_finished
	UIManager.restart_ui_request.emit()
	

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	return
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	return
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	return
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	return
	super.take_process(delta)

