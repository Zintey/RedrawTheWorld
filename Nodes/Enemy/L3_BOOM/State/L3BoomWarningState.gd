extends L3BoomState
class_name L3BoomWarningState

func enter() -> void:
	boom.animation_player.play("warning")

func exit() -> void:
	pass

func take_physics_process(delta: float) -> void:
	# 【安全检查】：除非玩家节点被销毁了（比如切换场景/重新开始），否则绝对不回 idle
	if not is_instance_valid(boom.target_body):
		switched_to.emit(self, "idle")
		return
		
	# 计算与玩家的距离
	var distance_to_player = boom.global_position.distance_to(boom.target_body.global_position)
	
	# 如果距离达到了自爆阈值，直接切入自爆状态！
	if distance_to_player <= boom.boom_distance:
		switched_to.emit(self, "boom_die")
		return
		
	# 追踪移动 (死咬不放)
	var move_dir = (boom.target_body.global_position - boom.global_position).normalized()
	boom.velocity = move_dir * boom.warning_speed
	
	# 翻转朝向
	if move_dir.x > 0:
		boom.turn_right()
	elif move_dir.x < 0:
		boom.turn_left()

	super.take_physics_process(delta)