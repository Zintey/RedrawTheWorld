extends DroneSegmentState
class_name DroneSegmentWarningState

var waypoint: Vector2
var roll_timer: Timer

func enter() -> void:
	drone.animation_player.play("warning")
	pick_new_waypoint()
	
	roll_timer = Timer.new()
	roll_timer.wait_time = 0.9
	roll_timer.autostart = true
	roll_timer.timeout.connect(_on_roll_dice)
	add_child(roll_timer)

func exit() -> void:
	if roll_timer: roll_timer.queue_free()

func _on_roll_dice() -> void:
	if randf() < 0.7:
		switched_to.emit(self, "fire")

func pick_new_waypoint() -> void:
	if not is_instance_valid(drone.target_body): return
	
	var angle: float
	# 80% 的概率在上半区游走，20% 的概率去下半区
	if randf() < 0.8:
		# 上半区：PI 到 TAU (即 180° ~ 360°)
		angle = randf_range(PI, TAU)
	else:
		# 下半区：0 到 PI (即 0° ~ 180°)
		angle = randf_range(0, PI)
		
	var dist = randf_range(drone.min_dist, drone.max_dist)
	waypoint = drone.target_body.global_position + Vector2(cos(angle), sin(angle)) * dist

func take_physics_process(delta: float) -> void:
	if not is_instance_valid(drone.target_body):
		switched_to.emit(self, "idle")
		return
		
	var dir = (waypoint - drone.global_position).normalized()
	drone.velocity = dir * drone.fly_speed
	
	# 【修改】：平滑转向目标点
	if drone.velocity.length() > 0.1:
		var target_angle = drone.velocity.angle()
		drone.center_point.rotation = lerp_angle(drone.center_point.rotation, target_angle, drone.turn_speed * delta)
		
	if drone.global_position.distance_to(waypoint) < 20.0:
		pick_new_waypoint()
		
	super.take_physics_process(delta)