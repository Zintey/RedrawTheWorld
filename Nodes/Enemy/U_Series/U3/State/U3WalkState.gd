extends U3State
class_name U3WalkState

@export var retreat_dist: float = 250.0 ## 玩家太近，赶紧后退拉开距离
@export var snipe_dist_min: float = 350.0 ## 完美狙击距离（进入这个距离就开始蹲下架枪）

func enter() -> void:
	u3.animation_player.play("walk")

func take_physics_process(delta: float) -> void:
	if not u3.has_target():
		u3.velocity.x = 0
		switched_to.emit(self, "idle")
		super.take_physics_process(delta)
		return

	# 永远盯着玩家
	u3.flip_towards(u3.target_body.global_position)
	
	var dist = abs(u3.target_body.global_position.x - u3.global_position.x)
	var y_dist = abs(u3.target_body.global_position.y - u3.global_position.y)
	
	# 如果高低差太大，不架枪，只移动
	if y_dist > 150:
		u3.velocity.x = 0
		switched_to.emit(self, "idle")
	else:
		if dist < retreat_dist:
			# 玩家太近！倒退风筝 (反向移动)
			u3.velocity.x = -u3.move_direction * u3.move_speed
		elif dist > snipe_dist_min:
			# 距离完美！停下，准备架枪！
			u3.velocity.x = 0
			switched_to.emit(self, "squrt")
			return
		else:
			# 在 250~350 的尴尬距离，继续往后退找好位置
			u3.velocity.x = -u3.move_direction * u3.move_speed

	super.take_physics_process(delta)