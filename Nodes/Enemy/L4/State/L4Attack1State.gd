extends L4State
class_name L4Attack1State

func enter() -> void:
	l4.velocity.x = 0.0
	# 开炮前，如果玩家换了方向，立刻转身对准玩家
	if is_instance_valid(l4.target_body):
		l4.flip_towards(l4.target_body.global_position)
		
	l4.animation_player.play("attack1")

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)
	
func take_process(delta: float) -> void:
	# 射击动作一旦开始不可打断（除非被打），播完后回到 idle 重新评估局势
	if not l4.animation_player.is_playing():
		switched_to.emit(self, "idle")