extends U2State
class_name U2HitState

@export var hit_stun_time: float = 0.2 ## 被打中的硬直时间（秒）。

var hit_timer: float = 0.0

func enter() -> void:
	hit_timer = 0.0
	u2.velocity.x = 0 # 强行打断移动
	u2.animation_player.play("hit") # 播放你做好的受击动画

func take_physics_process(delta: float) -> void:
	hit_timer += delta
	if hit_timer >= hit_stun_time:
		# 硬直结束，立刻切回 idle，如果玩家还在旁边，他会立马再次进入 walk 甚至 attack！
		switched_to.emit(self, "idle")
		return
		
	super.take_physics_process(delta)