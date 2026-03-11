extends TrackedCutterStateBase
class_name TrackedCutterFollowState

var can_switch_timer : Timer
var can_switch : bool = false

func enter() -> void:
	can_switch = false
	cutter.animation_player.play("idle")
	cutter.current_speed = cutter.follow_speed
	cutter.sprite_2d.material.set_shader_parameter("outline_size", 1.0)

func exit() -> void:
	pass

func take_physics_process(delta: float) -> void:
	if !cutter.check_can_forward():
		if cutter.move_direction == cutter.Direction.Left:
			cutter.turn_right()
		else:
			cutter.turn_left()
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if !cutter.check_lose_player() and cutter:
		if can_switch_timer:
			can_switch_timer.stop()
		can_switch = false
		can_switch_timer = Timer.new()
		can_switch_timer.wait_time = 2.0
		can_switch_timer.one_shot = true
		can_switch_timer.timeout.connect(func ():
			can_switch = true
		)
		add_child(can_switch_timer)
		can_switch_timer.start()

	if can_switch and cutter.check_lose_player():
		switched_to.emit(self, "idle")
		return 

	if cutter.check_player_in_attack1_area():
		switched_to.emit(self, "attack1")
		return 
	elif cutter.check_player_in_attack2_area():
		switched_to.emit(self, "attack2")
		return 
		
	super.take_process(delta)