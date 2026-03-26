extends U3State
class_name U3StandUpState

func enter() -> void:
	u3.velocity.x = 0
	u3.animation_player.play("stand_up")

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(_delta: float) -> void:
	# 起立动画播完
	if not u3.animation_player.is_playing() or u3.animation_player.current_animation != "stand_up":
		# 姿态重置为站立
		u3.is_crouching = false
		switched_to.emit(self, "idle")