extends TrackedCutterStateBase
class_name TrackedCutterAttack2State

func enter() -> void:
	cutter.animation_player.play("attack2")
	cutter.current_speed = cutter.attack2_speed
	cutter.attack_interval_timer.start()
	cutter.hit_box.damage = 2

func exit() -> void:
	if cutter.attack_interval_timer:
		cutter.attack_interval_timer.stop()
	cutter.hit_box.damage = 1

func camera_shake() -> void:
	EventBus.camera_shake.emit(Vector2(2.0,2.0),0.0)

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if !cutter.animation_player.is_playing():
		switched_to.emit(self, "stop")
		return 
	super.take_process(delta)