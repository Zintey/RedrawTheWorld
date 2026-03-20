extends PropState
class_name PropHitState

func enter() -> void:
	# 强行停止当前动画并重新播放，确保连续挨打时每次都会抖动
	prop.animation_player.stop()
	prop.animation_player.play("hit")

func take_process(_delta: float) -> void:
	# 严谨判断：动画确实名叫 hit，且已经播完了，才回到 idle
	if prop.animation_player.current_animation == "hit" and not prop.animation_player.is_playing():
		switched_to.emit(self, "idle")