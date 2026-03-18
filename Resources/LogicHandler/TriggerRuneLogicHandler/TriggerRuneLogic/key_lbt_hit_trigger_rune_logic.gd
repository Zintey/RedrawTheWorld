extends TriggerRuneLogicBase

func check_is_triggered(blackboard : Dictionary, caster : Node2D) -> bool:
	# 直接查黑板！
	return blackboard.has("LMB")