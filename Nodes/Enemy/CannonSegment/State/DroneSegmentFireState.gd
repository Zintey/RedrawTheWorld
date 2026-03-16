extends DroneSegmentState
class_name DroneSegmentFireState

var state_timer: float = 0.0
var fire_anim_length: float = 0.9 # 和你动画长度对应
var should_misfire: bool = false

func enter() -> void:
	state_timer = 0.0
	should_misfire = false
	drone.velocity = Vector2.ZERO # 悬停
	
	if not is_instance_valid(drone.target_body):
		should_misfire = true
		return
		
	# 简单的哑火机制：只要玩家在机头前方 180 度视野内，就开炮
	var dir_to_player = (drone.target_body.global_position - drone.global_position).normalized()
	var current_angle = drone.center_point.rotation
	
	if abs(angle_difference(current_angle, dir_to_player.angle())) > PI / 2.0:
		should_misfire = true 
	else:
		drone.animation_player.play("fire")

func take_process(delta: float) -> void:
	if should_misfire:
		switched_to.emit(self, "warning")
		return

	state_timer += delta
	if state_timer >= fire_anim_length:
		switched_to.emit(self, "warning")