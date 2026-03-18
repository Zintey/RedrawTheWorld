extends TriggerRuneLogicBase

func check_is_triggered(blackboard : Dictionary, caster : Node2D) -> bool:
	# 只要黑板上有受击便签，立刻返回 true！
	return blackboard.has("took_damage")