extends CutterState
class_name CutterAttackRotateState

func enter() -> void:
	cutter.velocity = Vector2.ZERO
	# 切入时保持原角度不变，直接开始播放狂转动画
	cutter.animation_player.play("attack_rotate")

func take_physics_process(delta: float) -> void:
	# 如果玩家没了，动画播完回 idle
	if not is_instance_valid(cutter.target_body):
		if not cutter.animation_player.is_playing():
			switched_to.emit(self, "idle")
		return
		
	# 方案 B：实时追踪！计算指向玩家的方向
	var dir = (cutter.target_body.global_position - cutter.global_position).normalized()
	
	# 速度跟着变
	cutter.velocity = dir * cutter.rotate_move_speed
	# 旋转枢纽（电锯头）也跟着实时变，保证电锯永远指着玩家钻！
	cutter.rotatable_pivot.rotation = dir.angle()
	
	super.take_physics_process(delta)

func take_process(delta: float) -> void:
	if not cutter.animation_player.is_playing():
		switched_to.emit(self, "idle")