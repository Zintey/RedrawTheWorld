extends PlayerState
class_name PlayerTeleportState

func enter() -> void:
	player.animation_player.play("Kaer/teleport")
	# print("go heare")
	player.rune_emitter.visible = false
	await player.animation_player.animation_finished
	switched_to.emit(self, "idle")
	

func exit() -> void:
	player.rune_emitter.visible = player.status_component.has_emitter

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

