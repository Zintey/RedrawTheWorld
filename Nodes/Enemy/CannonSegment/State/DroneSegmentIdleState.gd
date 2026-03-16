extends DroneSegmentState
class_name DroneSegmentIdleState

var move_dir: Vector2
var turn_timer: Timer

func enter() -> void:
	drone.animation_player.play("idle")
	pick_random_dir()
	
	turn_timer = Timer.new()
	turn_timer.wait_time = randf_range(2.0, 4.0)
	turn_timer.autostart = true
	turn_timer.timeout.connect(pick_random_dir)
	add_child(turn_timer)

func exit() -> void:
	if turn_timer: turn_timer.queue_free()

func pick_random_dir() -> void:
	move_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func take_physics_process(delta: float) -> void:
	if is_instance_valid(drone.target_body):
		switched_to.emit(self, "warning")
		return

	drone.velocity = move_dir * drone.fly_speed
	
	# 【修改】：使用平滑插值 (lerp_angle) 缓缓转向速度方向，产生漂移感
	if drone.velocity.length() > 0.1:
		var target_angle = drone.velocity.angle()
		drone.center_point.rotation = lerp_angle(drone.center_point.rotation, target_angle, drone.turn_speed * delta)
		
	super.take_physics_process(delta)