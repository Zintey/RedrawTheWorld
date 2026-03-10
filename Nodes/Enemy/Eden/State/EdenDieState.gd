# EdenDieState.gd
# Eden 死亡状态，在 CommonDieState 基础上加 Eden 特有的逻辑：
# 比如播放 summon 结束动画、触发关卡事件等。
# 如果 Eden 的死亡逻辑和通用的完全一样，可以直接用 CommonDieState，不需要这个文件。

extends CommonDieState
class_name EdenDieState

func enter() -> void:
	# 先执行通用死亡逻辑（emit die_signal、播 die 动画、queue_free boxes）
	super()
	# Eden 专属：触发关卡结束事件
	EventBus.boss_defeated.emit()  # 请确认你的 EventBus 里有这个信号，或换成你实际用的

func take_process(delta: float) -> void:
	# die 动画播完后可以在这里处理后续（淡出、掉落道具等）
	if not agent.animation_player.is_playing():
		# 例：播完后延迟消除
		await get_tree().create_timer(1.0).timeout
		agent.queue_free()
