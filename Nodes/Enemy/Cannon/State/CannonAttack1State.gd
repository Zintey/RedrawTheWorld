extends CannonState
class_name CannonAttack1State


func enter() -> void:
	agent.animation_player.play("attack1")
func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if agent.check_on_hit():
		switched_to.emit(self, "hit")
		return 
	if !agent.animation_player.is_playing():
		agent.fire(1.5)
		EventBus.camera_shake.emit(Vector2(3.0,3.0), 0.1)
		switched_to.emit(self, "stop1")
		return
	super.take_process(delta)
