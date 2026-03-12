extends EnemyStateBase 
class_name DroneState

# 强类型绑定，方便调用 drone 独有的变量
var drone : Drone :
	get: return agent as Drone

func enter() -> void:
	pass

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	# 独有的墙壁反弹逻辑
	var hitinfo: KinematicCollision2D = drone.move_and_collide(drone.current_move_speed * drone.current_move_direction * delta, true)
	if hitinfo:
		drone.current_move_direction += (drone.global_position - hitinfo.get_position()).normalized()
		drone.current_move_direction = drone.current_move_direction.normalized()

	drone.velocity = drone.current_move_speed * drone.current_move_direction
	
	# 使用基类提供的翻转方法
	if drone.current_move_direction.x > 0:
		drone.turn_right()
	elif drone.current_move_direction.x < 0:
		drone.turn_left()
	
	# agent.move_and_slide() 和 重力计算 已经被封装在 EnemyStateBase 的 super 里了
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	super.take_process(delta)