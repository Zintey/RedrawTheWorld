# EdenSwitchingFormState.gd
# 模式切换过渡动画状态，对应场景里已有的 "switching_form" 动画。
# 动画播完后根据 Eden 当前的 current_mode 决定去哪个状态。
# 这个状态由 eden.gd 的 switch_mode() 调用 state_machine.switch_to("switching_form") 触发。

extends EdenState
class_name EdenSwitchingFormState

func enter() -> void:
	agent.animation_player.play("switching_form")

	# 模式1时 HurtBox 关闭（玩家打不到），模式2时开启
	# 注意：这里在切换动画开始时就调整碰撞，
	# 如果你想在动画结束后再改，把这两行移到 take_process 的 is_playing 判断里
	agent.hurt_box.monitoring = agent.is_mode_2()
	agent.hurt_box.monitorable = agent.is_mode_2()

func exit() -> void:
	pass

func take_process(delta: float) -> void:
	# 切换动画期间不响应受击，保持动画完整播完
	if not agent.animation_player.is_playing():
		switched_to.emit(self, "idle")
		return

	super.take_process(delta)
