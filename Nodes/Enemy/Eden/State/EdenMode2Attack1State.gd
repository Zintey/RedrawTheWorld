# EdenMode2Attack1State.gd
# 模式2 攻击1：玩家可以打到 Eden 时的近战攻击。
# 具体动画名请替换成你实际的模式2攻击动画。

extends EdenState
class_name EdenMode2Attack1State

func enter() -> void:
	# TODO: 替换成模式2对应的攻击动画名
	agent.animation_player.play("attack2")

func exit() -> void:
	pass

func take_process(delta: float) -> void:
	if agent.check_on_hit():
		switched_to.emit(self, "hit")
		return

	if not agent.animation_player.is_playing():
		switched_to.emit(self, "idle")
		return

	super.take_process(delta)
