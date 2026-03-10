extends PlayerState 
class_name  PlayerRunState

func enter() -> void:
	player.animation_player.play("Kaer/run")
	player.stats_component.current_accelerate = player.stats_component.floor_accelerate
	player.stats_component.current_speed = player.stats_component.run_speed
@onready var run_sfx: AudioStreamPlayer = %run_sfx

func play_sfx():
	run_sfx.play()

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	#if abs(player.velocity.x) <= player.stats_component.walk_speed:
		#switched_to.emit(self, "walk")
	
	if abs(player.velocity.x) <= abs(player.stats_component.get_force().x):
		switched_to.emit(self, "idle")
	
	if player.velocity.y > 0:
		switched_to.emit(self, "fall")
	
	if player.velocity.y < -18:
		switched_to.emit(self, "up_to_air")

	if player.is_on_floor() and player.jump_request_timer.time_left > 0:
		switched_to.emit(self, "jump")
	super.take_process(delta)
