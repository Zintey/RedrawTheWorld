extends TrackedCutterStateBase
class_name TrackedCutterFollowState

var can_switch_timer : Timer
var can_switch : bool = false

func enter() -> void:
	can_switch = false
	agent.animation_player.play("idle")
	agent.current_speed = agent.follow_speed
	agent.sprite_2d.material.set_shader_parameter("outline_size", 1.0)


func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:

	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	if !agent.check_can_forward():
		if agent.move_direction == agent.Direction.Left:
			agent.move_direction = agent.Direction.Right
			agent.turn_right()
		else:
			agent.move_direction = agent.Direction.Left
			agent.turn_left()
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if agent.check_on_hit():
		switched_to.emit(self, "hit")
		return 

	if !agent.check_lose_player() and agent:
		if can_switch_timer:
			can_switch_timer.stop()
		can_switch = false
		can_switch_timer = Timer.new()
		can_switch_timer.wait_time = 2.0
		can_switch_timer.one_shot = true
		can_switch_timer.timeout.connect(func ():
			can_switch = true
			# print("time out")
		)
		add_child(can_switch_timer)
		can_switch_timer.start()

	if can_switch and agent.check_lose_player():
		switched_to.emit(self, "idle")
		return 
	
	if agent.attack_interval_timer.time_left == 0:
		if agent.check_player_in_attack2_area():
			if randf_range(0, 1) <= 0.6:
				switched_to.emit(self, "attack2")
			else:
				switched_to.emit(self, "attack1")
			return 
		
		
		if agent.check_player_in_attack1_area():
			if randf_range(0, 1) <= 0.8:
				switched_to.emit(self, "attack1")
			else:
				switched_to.emit(self, "attack2")
			return 
		
	super.take_process(delta)
