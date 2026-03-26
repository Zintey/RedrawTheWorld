extends U3State
class_name U3IdleState

var idle_timer: float = 0.0

func enter() -> void:
	idle_timer = 0.0
	u3.velocity.x = 0
	u3.animation_player.play("idle")

func take_physics_process(delta: float) -> void:
	if u3.has_target():
		u3.flip_towards(u3.target_body.global_position)
		
	idle_timer += delta
	# 极短的反应时间，马上开始评估走位
	if idle_timer >= 0.3:
		switched_to.emit(self, "walk")
		return
		
	super.take_physics_process(delta)