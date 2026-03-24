extends EnemyStateBase 
class_name CannonState

# 强类型绑定
var cannon : Cannon :
	get: return agent as Cannon

func enter() -> void:
	pass

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	if cannon.target_body:
		cannon.target_position = cannon.target_body.global_position
		
	var target_rotation = (cannon.target_position - cannon.global_position).angle()
	
	# 【修复】：使用 wrapf 计算最短旋转角度差，完美解决 180 度交界处的乱转
	var angle_diff = wrapf(target_rotation - cannon.global_rotation, -PI, PI)
	
	# 加入 0.05 的死区，防止瞄准后在原地左右抽搐
	if angle_diff > 0.05:
		cannon.rotate_direction = Cannon.RotateDirection.Right
	elif angle_diff < -0.05:
		cannon.rotate_direction = Cannon.RotateDirection.Left
	else:
		cannon.rotate_direction = Cannon.RotateDirection.Stop
		cannon.global_rotation = target_rotation # 完美对齐
	
	if (!cannon.check_can_turn_left() and cannon.rotate_direction == Cannon.RotateDirection.Left) or (!cannon.check_can_turn_right() and cannon.rotate_direction == Cannon.RotateDirection.Right):
		cannon.rotate_direction = Cannon.RotateDirection.Stop
	
	if cannon.on_follow:
		cannon.global_rotation += cannon.current_rotate_speed * cannon.rotate_direction * delta
	
	if !cannon.is_summoned:
		super.take_physics_process(delta)