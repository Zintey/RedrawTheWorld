extends TrackedCutterStateBase
class_name TrackedCutterStopState

var timer : Timer

func enter() -> void:
	agent.animation_player.play("idle")
	agent.current_speed = 0.0
	timer = Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	switched_to.emit(self, "idle")

func exit() -> void:
	if timer:
		timer.stop()

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
	super.take_process(delta)

