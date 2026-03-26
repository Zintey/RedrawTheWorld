extends U2State
class_name U2WalkState

@export var attack_range: float = 55.0 ## 拔刀距离！进入这个距离立刻砍人！

func enter() -> void:
	u2.animation_player.play("walk")

func take_physics_process(delta: float) -> void:
	if not u2.has_target():
		u2.velocity.x = 0
		switched_to.emit(self, "idle")
		super.take_physics_process(delta)
		return

	# 1. 永远面向玩家
	u2.flip_towards(u2.target_body.global_position)
	
	# 2. 疯狗冲锋
	u2.velocity.x = u2.move_direction * u2.move_speed
	
	# 3. 距离判断：到了就砍！
	var dist = abs(u2.target_body.global_position.x - u2.global_position.x)
	var y_dist = abs(u2.target_body.global_position.y - u2.global_position.y)
	
	# 如果在同一个水平面上（容错高度 100），并且进入了攻击距离
	if y_dist <= 100.0 and dist <= attack_range:
		switched_to.emit(self, "attack")
		return

	super.take_physics_process(delta)