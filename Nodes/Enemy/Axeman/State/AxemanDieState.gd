extends AxemanState
class_name AxemanDieState

func enter() -> void:
	boss.velocity.x = 0
	boss.animation_player.play("die")
	
	boss.set_collision_layer_value(1, false) 
	boss.set_collision_mask_value(1, false)
	
	if is_instance_valid(boss.hurt_box):
		boss.hurt_box.queue_free()
		
	# 注意：如果你把 HitBox 移进了 CenterPoint 里，find_child 依然能全局找出来销毁
	var hit_box = boss.find_child("HitBox", true, false)
	if is_instance_valid(hit_box):
		hit_box.queue_free()

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)