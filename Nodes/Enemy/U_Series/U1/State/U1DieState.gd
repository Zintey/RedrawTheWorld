extends U1State
class_name U1DieState

func enter() -> void:
	u1.velocity.x = 0
	u1.animation_player.play("die")
	
	# 关闭所有碰撞，变成尸体
	u1.set_collision_layer_value(1, false) 
	u1.set_collision_mask_value(1, false)
	
	if is_instance_valid(u1.hurt_box):
		u1.hurt_box.queue_free()

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)