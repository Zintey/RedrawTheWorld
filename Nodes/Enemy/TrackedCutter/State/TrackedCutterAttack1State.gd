extends TrackedCutterStateBase
class_name TrackedCutterAttack1State

func enter() -> void:
	cutter.animation_player.play("attack1")
	cutter.current_speed = cutter.attack1_speed
	cutter.attack_interval_timer.start()
	cutter.hit_box.damage = 2

func exit() -> void:
	cutter.hit_box.damage = 1

func camera_shake() -> void:
	EventBus.camera_shake.emit(Vector2(3.0,3.0),0.08)

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	if !cutter.animation_player.is_playing():
		switched_to.emit(self, "stop")
		return 
	super.take_process(delta)