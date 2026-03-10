# EdenIdleState.gd
# Eden 的待机状态，两种模式共用同一个 idle 状态。
# 根据当前模式决定播放哪个 idle 动画（idle_1 / idle_2），
# 以及收到攻击触发时跳转到哪个攻击状态。

extends EdenState
class_name EdenIdleState

func enter() -> void:
	if agent.is_mode_1():
		# 模式1：idle_1 动画，HitBox 关闭（玩家打不到）
		agent.animation_player.play("idle_1")
	else:
		# 模式2：idle_2 动画，HitBox 开启
		agent.animation_player.play("idle_2")

func exit() -> void:
	pass

func take_process(delta: float) -> void:
	if agent.check_on_hit():
		switched_to.emit(self, "hit")
		return

	# 模式1：远程攻击循环
	if agent.is_mode_1():
		if not agent.animation_player.is_playing():
			# idle_1 播完后随机选攻击1或攻击2
			if randf() < 0.5:
				switched_to.emit(self, "mode1_attack1")
			else:
				switched_to.emit(self, "mode1_attack2")
			return

	# 模式2：等待玩家进入近战范围再出招
	if agent.is_mode_2():
		if not agent.animation_player.is_playing():
			switched_to.emit(self, "mode2_attack1")
			return

	super.take_process(delta)
