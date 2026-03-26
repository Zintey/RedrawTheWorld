extends U2State
class_name U2DieState

func enter() -> void:
	u2.velocity.x = 0
	u2.animation_player.play("die")
	
	# 尸体物理碰撞关闭
	u2.set_collision_layer_value(1, false) 
	u2.set_collision_mask_value(1, false)
	
	if is_instance_valid(u2.hurt_box):
		u2.hurt_box.queue_free()
		
	# 销毁你的双刃伤害框！防止尸体还能杀人
	var hit_box = u2.find_child("HitBox", true, false)
	if is_instance_valid(hit_box):
		hit_box.queue_free()

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)