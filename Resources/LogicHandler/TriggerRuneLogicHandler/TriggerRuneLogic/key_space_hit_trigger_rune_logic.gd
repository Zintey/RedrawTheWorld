extends TriggerRuneLogicBase


func check_is_triggered(caster : Node2D) -> bool:
	return Input.is_action_just_pressed("Key_Space")
