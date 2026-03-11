extends StateBase
class_name EnemyStateBase

# 强类型绑定：子类可以直接敲出 agent.turn_left() 或 agent.health_component
@export var agent: EnemyBase

func take_physics_process(delta: float) -> void:
	# 大部分怪物都需要 move_and_slide，基类可以帮你统一调用
	# 但具体的速度 (velocity.x) 设置留给子状态自己写
	agent.move_and_slide()