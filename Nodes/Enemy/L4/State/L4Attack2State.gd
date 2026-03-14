extends L4State
class_name L4Attack2State

func enter() -> void:
	l4.animation_player.play("attack2")

func take_physics_process(delta: float) -> void:
	if not is_instance_valid(l4.target_body):
		switched_to.emit(self, "idle")
		return
		
	# 永远面朝玩家
	l4.flip_towards(l4.target_body.global_position)
	
	# 后背撞墙（死角困境）：放弃冲刺逃跑，原地反击贴脸开炮！
	if l4.is_on_wall():
		switched_to.emit(self, "attack1")
		return
		
	# 退到了安全距离外，停下来开炮
	var dist = l4.global_position.distance_to(l4.target_body.global_position)
	if dist >= l4.safe_distance + 20.0:
		switched_to.emit(self, "attack1")
		return
		
	# 向后倒退滑动（速度方向与朝向相反）
	var backward_dir = -1.0 if l4.target_body.global_position.x > l4.global_position.x else 1.0
	l4.velocity.x = backward_dir * l4.dash_speed
	
	# 不检测悬崖，直接调用基类让它可能自然掉下悬崖
	super.take_physics_process(delta)