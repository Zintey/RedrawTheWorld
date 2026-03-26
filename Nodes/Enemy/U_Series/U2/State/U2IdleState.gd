extends U2State
class_name U2IdleState

@export var idle_duration: float = 1.0 ## 攻击后的喘息时间。越短越像疯狗。

var idle_timer: float = 0.0

func enter() -> void:
	idle_timer = 0.0
	u2.velocity.x = 0
	u2.animation_player.play("idle")

func take_physics_process(delta: float) -> void:
	# 盯着玩家看
	if u2.has_target():
		u2.flip_towards(u2.target_body.global_position)
		
	idle_timer += delta
	if idle_timer >= idle_duration:
		switched_to.emit(self, "walk")
		return
		
	super.take_physics_process(delta)