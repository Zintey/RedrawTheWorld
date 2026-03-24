extends AxemanState
class_name AxemanAttack1State

func enter() -> void:
	boss.velocity.x = 0
	# 仅仅在刚进状态时转一次身。由于 take_physics_process 里没写追踪逻辑，就形成了完美的“动画硬直锁定”！
	if boss.has_target():
		boss.flip_towards(boss.target_body.global_position)
	
	boss.attack_1_timer = boss.attack_1_cd_max
	boss.animation_player.play("attack_1")

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(_delta: float) -> void:
	if not boss.animation_player.is_playing() or boss.animation_player.current_animation != "attack_1":
		switched_to.emit(self, "idle")