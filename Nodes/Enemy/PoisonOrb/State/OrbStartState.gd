extends OrbState
class_name OrbStartState

func enter() -> void:
	orb.animation_player.play("start")

func take_physics_process(delta: float) -> void:
	orb.velocity.y += orb.gravity * delta
	
	var collided = orb.move_and_slide()
	
	if collided:
		if orb.is_on_floor():
			# 只要有一丝接触地面，就算落地，变成毒水
			switched_to.emit(self, "on_land")
		elif orb.is_on_wall() or orb.is_on_ceiling():
			# 撞到墙壁或天花板：强行清空水平速度，让它贴着墙垂直下落
			orb.velocity.x = 0
			
	# 【核心修复】：防止死角卡死的关键
	# 只有在既没有挨着墙，也没有挨着天花板的时候，才允许旋转
	if not orb.is_on_wall() and not orb.is_on_ceiling():
		# 加一个小保险：速度不为0时才旋转，防止角度归零乱跳
		if orb.velocity.length() > 10.0:
			orb.rotation = orb.velocity.angle()
