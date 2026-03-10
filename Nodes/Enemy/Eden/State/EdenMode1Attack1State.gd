# EdenMode1Attack1State.gd
# 模式1 攻击1：对应场景里的 attack1_aim + attack1_sprint 动画序列。
# 模式1下玩家无法接触到 Eden，这是远程/投射物类攻击。

extends EdenState
class_name EdenMode1Attack1State

func enter() -> void:
	# 先播瞄准动画
	agent.animation_player.play("attack1_aim")

func exit() -> void:
	pass

func take_process(delta: float) -> void:
	if agent.check_on_hit():
		switched_to.emit(self, "hit")
		return

	if not agent.animation_player.is_playing():
		var current_anim = agent.animation_player.current_animation
		match current_anim:
			"attack1_aim":
				# 瞄准结束，播冲刺/发射动画
				agent.animation_player.play("attack1_sprint")
			"attack1_sprint":
				# 发射攻击特效，回 idle
				agent.fire_attack_fx()
				switched_to.emit(self, "idle")
		return

	super.take_process(delta)
