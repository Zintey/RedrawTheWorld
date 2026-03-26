extends U2State
class_name U2AttackState

func enter() -> void:
	# 拔刀瞬间，刹车停步
	u2.velocity.x = 0
	
	# 砍之前最后一次确认方向，之后绝对不转身
	if u2.has_target():
		u2.flip_towards(u2.target_body.global_position)
		
	u2.animation_player.play("attack")

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(_delta: float) -> void:
	# 动画播完，切回 Idle 喘息
	if not u2.animation_player.is_playing() or u2.animation_player.current_animation != "attack":
		switched_to.emit(self, "idle")