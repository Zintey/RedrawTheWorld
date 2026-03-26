extends U3State
class_name U3DieState

func enter() -> void:
	u3.velocity.x = 0
	
	# 核心：根据姿态记忆，播放对应的死亡动画！
	if u3.is_crouching:
		u3.animation_player.play("squrt_die")
	else:
		u3.animation_player.play("stand_die")
	
	# 物理超度
	u3.set_collision_layer_value(1, false) 
	u3.set_collision_mask_value(1, false)
	
	if is_instance_valid(u3.hurt_box):
		u3.hurt_box.queue_free()

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)