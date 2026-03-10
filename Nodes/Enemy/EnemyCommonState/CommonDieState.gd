# CommonDieState.gd
# 合并 CannonDieState / TrackedCutterDieState 的共同逻辑。
# DroneDieState 有额外操作（开启重力、控制子节点 Cannon），
# 所以 Drone 继续用自己的 DroneDieState extends CommonDieState，只补充差异部分。
#
# 用法：挂到各敌人 StateMachine 下的 "die" 节点。
# 如果某个敌人死亡时还有额外逻辑，就写一个子类 extends CommonDieState，
# override enter()，先 super() 再加自己的操作。

extends EnemyState
class_name CommonDieState

func enter() -> void:
	agent.die_signal.emit()
	agent.animation_player.play("die")
	agent.sprite_2d.material.set_shader_parameter("hit", false)
	agent.sprite_2d.material.set_shader_parameter("outline_size", 0.0)

	if agent.hurt_box:
		agent.hurt_box.queue_free()
	if agent.hit_box:
		agent.hit_box.queue_free()

func exit() -> void:
	pass

func take_physics_process(delta: float) -> void:
	# die 状态下停止所有物理处理
	pass

func take_process(delta: float) -> void:
	pass
