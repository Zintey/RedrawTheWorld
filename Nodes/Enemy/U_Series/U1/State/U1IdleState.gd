extends U1State
class_name U1IdleState

var idle_timer: float = 0.0

func enter() -> void:
	idle_timer = 0.0
	u1.velocity.x = 0
	u1.animation_player.play("idle")

func take_physics_process(delta: float) -> void:
	# 只要有目标，就算发呆也要拿枪指着他
	if u1.has_target():
		u1.flip_towards(u1.target_body.global_position)
		
	idle_timer += delta
	# 稍微发呆 0.5 秒就进入战术走位
	if idle_timer >= 0.5:
		switched_to.emit(self, "walk")
		return
		
	super.take_physics_process(delta)