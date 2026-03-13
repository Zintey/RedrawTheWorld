extends L3BoomState
class_name L3BoomBoomDieState

func enter() -> void:
	# 停止移动，播放自爆动画
	boom.velocity = Vector2.ZERO
	boom.animation_player.play("boom_die")
	
	# 移除受伤框，防止在爆炸动画期间还能被反复鞭尸
	if is_instance_valid(boom.hurt_box):
		boom.hurt_box.queue_free()

	# 等待爆炸动画播放完毕（动画里包含了 HitBox 变大的过程）
	await boom.animation_player.animation_finished
	boom.queue_free()

func exit() -> void:
	pass

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)