extends TrackedCutterStateBase
class_name TrackedCutterAttack1State

# var attack_interval_timer : Timer

func enter() -> void:
	agent.animation_player.play("attack1")
	agent.current_speed = agent.attack1_speed
	agent.attack_interval_timer.start()
	agent.hurt_box.damage = 2.0

func exit() -> void:
	agent.hurt_box.damage = 1.0
	# if attack_interval_timer:
		# attack_interval_timer.stop()

func camera_shake() -> void:
	EventBus.camera_shake.emit(Vector2(3.0,3.0),0.08)

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	# if !agent.check_can_forward():
		# if agent.move_direction == agent.Direction.Left:
			# agent.move_direction = agent.Direction.Right
			# agent.turn_right()
		# else:
			# agent.move_direction = agent.Direction.Left
			# agent.turn_left()
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	
	if agent.check_on_hit():
		switched_to.emit(self, "hit")
		return 
	if !agent.animation_player.is_playing():
		switched_to.emit(self, "stop")
		return 
		# agent.animation_player.play("idle")
		# agent.current_speed = 0.0
		# if attack_interval_timer:
		# 	attack_interval_timer.stop()
		# attack_interval_timer = Timer.new()
		# attack_interval_timer.one_shot = true
		# attack_interval_timer.wait_time = 1.1
		# add_child(attack_interval_timer)
		# attack_interval_timer.start()
		
		# await attack_interval_timer.timeout
		# switched_to.emit(self, "idle")
	
	super.take_process(delta)
