extends EnemyStateBase
class_name TrackedCutterStateBase

var cutter : TrackedCutter :
	get: return agent as TrackedCutter

func enter() -> void:
	pass

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	if cutter.move_direction:
		cutter.velocity.x = cutter.move_direction * cutter.current_speed
	else:
		cutter.velocity.x = move_toward(cutter.velocity.x, 0, cutter.current_speed)

	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	super.take_process(delta)