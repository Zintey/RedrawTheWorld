extends U3State
class_name U3SqurtState

func enter() -> void:
	u3.velocity.x = 0
	# 锁定姿态：我蹲下了！
	u3.is_crouching = true
	
	if u3.has_target():
		u3.flip_towards(u3.target_body.global_position)
		
	u3.animation_player.play("squrt")

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(_delta: float) -> void:
	# 蹲下动画播完，强制切入攻击！
	if not u3.animation_player.is_playing() or u3.animation_player.current_animation != "squrt":
		switched_to.emit(self, "attack")