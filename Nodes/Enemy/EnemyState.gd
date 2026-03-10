# EnemyState.gd
# 替代现在 CannonState / DroneState / TrackedCutterStateBase 三个几乎一样的文件。
# 所有敌人的具体状态改成 extends EnemyState，不再需要各自的中间基类。
#
# 迁移方式：
#   CannonIdleState:    extends CannonState       → extends EnemyState
#   DroneHitState:      extends DroneState        → extends EnemyState
#   TrackedCutterXxx:   extends TrackedCutterStateBase → extends EnemyState
#   Eden的所有状态:     直接 extends EnemyState

extends StateBase
class_name EnemyState

# agent 统一是 EnemyAgent 类型，访问 check_on_hit / check_is_die / 
# animation_player / status_component 等都不需要 cast
@export var agent: EnemyAgent

func enter() -> void:
	pass

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta: float) -> void:
	super.take_process(delta)
