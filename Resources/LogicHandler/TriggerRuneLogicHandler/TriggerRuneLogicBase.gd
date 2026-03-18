extends RefCounted
class_name TriggerRuneLogicBase

# 【修改】：接收 blackboard 参数
func check_is_triggered(blackboard : Dictionary, caster : Node2D) -> bool:
    return false