extends TriggerRuneLogicBase

func check_is_triggered(blackboard : Dictionary, caster : Node2D) -> bool:
	return blackboard.has("RMB")