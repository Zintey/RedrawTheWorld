extends U1State
class_name U1AttackState

func enter() -> void:
	u1.velocity.x = 0
	# 开枪前最后一次锁定方向，动画期间锁死
	if u1.has_target():
		u1.flip_towards(u1.target_body.global_position)
		
	u1.animation_player.play("attack")
	# ⚠️ 记得在 AnimationPlayer 的 "attack" 动画中，
	# 插入调用 `fire_bullet()` 方法的轨道！

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(_delta: float) -> void:
	if not u1.animation_player.is_playing() or u1.animation_player.current_animation != "attack":
		switched_to.emit(self, "idle")