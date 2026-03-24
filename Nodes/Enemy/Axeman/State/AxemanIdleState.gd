extends AxemanState
class_name AxemanIdleState

@export_category("Idle Settings")
@export var idle_duration: float = 1.0 ## 每次释放完技能强制发呆的持续时间（秒）。也就是留给玩家疯狂输出的“破绽窗口”。值越小，Boss 攻势越疯狗。

var idle_timer: float = 0.0

func enter() -> void:
	idle_timer = 0.0
	boss.velocity.x = 0
	boss.animation_player.play("idle")

func take_physics_process(delta: float) -> void:
	# 即使在发呆，也会盯着玩家看
	if boss.has_target():
		boss.flip_towards(boss.target_body.global_position)
	
	idle_timer += delta
	if idle_timer >= idle_duration:
		switched_to.emit(self, "walk")
		return
		
	super.take_physics_process(delta)