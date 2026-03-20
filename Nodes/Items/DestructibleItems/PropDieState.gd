extends PropState
class_name PropDieState

func enter() -> void:
	# 播放 die 动画（你在动画里已经把 RigidBody2D 的 sleeping 关掉了，它会自然掉落）
	prop.animation_player.play("die")
	
	# 【核心逻辑】：彻底销毁 HurtBox，玩家再挥刀就完全砍不到了！
	if is_instance_valid(prop.hurt_box):
		prop.hurt_box.queue_free()
		
	# 如果你连 HealthComponent 也不想要了，也可以一并销毁释放内存
	if is_instance_valid(prop.health_component):
		prop.health_component.queue_free()