extends TrackedCutterStateBase
class_name TrackedCutterStopState

var timer : Timer

func enter() -> void:
	cutter.animation_player.play("idle")
	cutter.current_speed = 0.0
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

func take_process(delta : float) -> void:
	super.take_process(delta)