extends EnemyStateBase # 继承自你的基础状态类
class_name UniversalHitState

@export var next_state_after_hit: String = "idle" # 可以在检查器中随意修改默认切回的状态

const Hit_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

var enemy: EnemyBase :
	get: return agent as EnemyBase

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy.animation_player.play("hit")
	
	# if is_instance_valid(enemy.hurt_box):
		# enemy.hurt_box.is_invincible = true
		
	var hit_dust: Node2D = Hit_SCENE.instantiate()
	hit_dust.global_position = enemy.global_position
	get_tree().current_scene.add_child(hit_dust)
	
	super()

func exit() -> void:
	# if is_instance_valid(enemy.hurt_box):
		# enemy.hurt_box.is_invincible = false
	super()

func take_process(delta: float) -> void:
	# 动画播完（时间和你在编辑器里 K 的动画严格一致），自动退出
	if not enemy.animation_player.is_playing():
		switched_to.emit(self, next_state_after_hit)