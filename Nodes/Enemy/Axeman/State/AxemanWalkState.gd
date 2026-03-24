extends AxemanState
class_name AxemanWalkState

@export_category("Walk & AI Settings")
@export var attack_2_range: float = 60.0 ## 苍蝇拍绝对禁区：玩家距离小于这个值，立刻无脑触发近战二连击。
@export var attack_1_min_range: float = 120.0 ## 剑气触发距离：玩家距离大于这个值，且剑气 CD 好了，就会放剑气逼玩家跳跃。
@export var y_detection_limit: float = 100.0 ## 高低差限制：如果玩家站在比 Boss 高或低超过这个值的台阶上，Boss 就不放技能，只会傻走（防止剑气空放）。

func enter() -> void:
	boss.animation_player.play("walk")

func take_physics_process(delta: float) -> void:
	if not boss.has_target():
		boss.velocity.x = 0
		super.take_physics_process(delta)
		return

	# 1. 调用基类的自动索敌转身
	boss.flip_towards(boss.target_body.global_position)
	
	# 2. 移动
	boss.velocity.x = boss.move_direction * boss.move_speed
	
	# 3. 距离决策 AI
	var dist = abs(boss.target_body.global_position.x - boss.global_position.x)
	var y_dist = abs(boss.target_body.global_position.y - boss.global_position.y)
	
	if y_dist <= y_detection_limit: 
		# 贴脸距离
		if dist < attack_2_range:
			switched_to.emit(self, "attack_2")
			return
		# 中远距离
		elif dist > attack_1_min_range and boss.attack_1_timer <= 0:
			switched_to.emit(self, "attack_1")
			return

	super.take_physics_process(delta)