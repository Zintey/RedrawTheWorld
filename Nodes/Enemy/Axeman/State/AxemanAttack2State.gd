extends AxemanState
class_name AxemanAttack2State

func enter() -> void:
	boss.velocity.x = 0
	if boss.has_target():
		boss.flip_towards(boss.target_body.global_position)
	
	boss.animation_player.play("attack_2")

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(_delta: float) -> void:
	if not boss.animation_player.is_playing() or boss.animation_player.current_animation != "attack_2":
		switched_to.emit(self, "idle")