# EdenMode1Attack2State.gd
# 模式1 攻击2：对应场景里的 attack2 动画（循环旋转攻击）。

extends EdenState
class_name EdenMode1Attack2State

# 攻击2持续几轮后才停，用 @export 让策划在编辑器里调
@export var attack_loop_count: int = 2
var _current_loop: int = 0

func enter() -> void:
	_current_loop = 0
	agent.animation_player.play("attack2")

func exit() -> void:
	pass

func take_process(delta: float) -> void:
	if agent.check_on_hit():
		switched_to.emit(self, "hit")
		return

	if not agent.animation_player.is_playing():
		_current_loop += 1
		if _current_loop >= attack_loop_count:
			switched_to.emit(self, "idle")
		else:
			agent.animation_player.play("attack2")
		return

	super.take_process(delta)
