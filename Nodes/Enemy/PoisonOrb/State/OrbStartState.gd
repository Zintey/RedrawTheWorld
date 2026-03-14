extends OrbState
class_name OrbStartState

func enter() -> void:
	orb.animation_player.play("start")

func take_physics_process(delta: float) -> void:
	orb.velocity.y += orb.gravity * delta
	
	# 动态旋转：让毒球的贴图永远指向飞行的方向
	orb.rotation = orb.velocity.angle()
	
	orb.move_and_slide()
	
	# 环境碰撞区分：打到地面变成毒水，打到墙壁直接销毁
	if orb.is_on_floor():
		switched_to.emit(self, "on_land")
	# elif orb.is_on_wall():
		# switched_to.emit(self, "end")
