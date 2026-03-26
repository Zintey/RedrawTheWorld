extends U1State
class_name U1WalkState

@export_category("Gunner Tactics")
@export var retreat_dist: float = 120.0 ## 风筝距离：太近就后退
@export var attack_dist: float = 250.0  ## 射击距离：在这距离内停下开火

func enter() -> void:
	u1.animation_player.play("walk")

func take_physics_process(delta: float) -> void:
	if not u1.has_target():
		u1.velocity.x = 0
		switched_to.emit(self, "idle")
		super.take_physics_process(delta)
		return

	# 1. 永远面向玩家
	u1.flip_towards(u1.target_body.global_position)

	# 2. 距离判断
	var dist = abs(u1.target_body.global_position.x - u1.global_position.x)
	var y_dist = abs(u1.target_body.global_position.y - u1.global_position.y)
	
	if y_dist > 150: 
		# 不在同一层，随便走走或者站着
		u1.velocity.x = 0
	else:
		if dist < retreat_dist:
			# 【风筝逻辑】：反向移动（后退）！注意这里用的是 -u1.move_direction
			u1.velocity.x = -u1.move_direction * u1.move_speed
			# 如果你有向后走的动画，可以在这里播放：u1.animation_player.play("walk_back")
		elif dist > attack_dist:
			# 【追击逻辑】：正向移动
			u1.velocity.x = u1.move_direction * u1.move_speed
		else:
			# 【开火逻辑】：处于最佳射击区间，停下开火！
			u1.velocity.x = 0
			switched_to.emit(self, "attack")
			return

	super.take_physics_process(delta)