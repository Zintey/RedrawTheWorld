extends U3State
class_name U3HitState

func enter() -> void:
	u3.velocity.x = 0
	# 挨打瞬间，破防！姿态强行打回站立
	u3.is_crouching = false 
	
	# 播放你在场景里写好的 hit 动画 (它会自动改 shader 的 hit 属性)
	u3.animation_player.play("hit")

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(_delta: float) -> void:
	# 硬直播完 (你的 hit 动画只有 0.2 秒，刚刚好)
	if not u3.animation_player.is_playing() or u3.animation_player.current_animation != "hit":
		switched_to.emit(self, "idle")