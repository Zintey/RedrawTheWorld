extends CannonState
class_name CannonAttack2State

func enter() -> void:
	agent.animation_player.play("attack2")
	agent.on_follow = true

func exit() -> void:
	agent.on_follow = false

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
		agent.fire()
		switched_to.emit(self, "stop2")
		return
	super.take_process(delta)

