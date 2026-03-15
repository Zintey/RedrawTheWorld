extends CutterState
class_name CutterIdleState

var move_dir: Vector2
var turn_timer: Timer

func enter() -> void:
	cutter.animation_player.play("idle")
	pick_random_dir()
	
	turn_timer = Timer.new()
	turn_timer.wait_time = randf_range(2.0, 3.5)
	turn_timer.autostart = true
	turn_timer.timeout.connect(pick_random_dir)
	add_child(turn_timer)

func exit() -> void:
	if turn_timer: turn_timer.queue_free()

func pick_random_dir() -> void:
	move_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func take_physics_process(delta: float) -> void:
	# 发现玩家，判定距离并分发状态
	if is_instance_valid(cutter.target_body):
		var dist = cutter.global_position.distance_to(cutter.target_body.global_position)
		if dist > cutter.attack_threshold:
			switched_to.emit(self, "attack_sprint")
		else:
			switched_to.emit(self, "attack_rotate")
		return

	# 游走移动
	cutter.velocity = move_dir * cutter.idle_speed
	
	# 让枢纽（头）始终朝向飞行的方向
	if cutter.velocity.length() > 0.1:
		cutter.rotatable_pivot.rotation = cutter.velocity.angle()
		
	super.take_physics_process(delta)