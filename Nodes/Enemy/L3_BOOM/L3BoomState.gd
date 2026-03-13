extends EnemyStateBase
class_name L3BoomState

var boom : L3Boom :
	get: return agent as L3Boom

func enter() -> void:
	pass

func exit() -> void:
	pass

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)