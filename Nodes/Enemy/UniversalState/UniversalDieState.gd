extends EnemyStateBase
class_name UniversalDieState

var enemy: EnemyBase :
	get: return agent as EnemyBase

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy.animation_player.play("die")
	
	# 剥离伤害和受击判定
	if is_instance_valid(enemy.hurt_box):
		enemy.hurt_box.queue_free()
	
	# 通用写法：尝试寻找 HitBox（考虑到可能在不同层级）
	var hit_box = enemy.find_child("HitBox", true, false)
	if is_instance_valid(hit_box):
		hit_box.queue_free()
		
	await enemy.animation_player.animation_finished
	enemy.queue_free()