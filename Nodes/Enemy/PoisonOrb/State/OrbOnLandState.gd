extends OrbState
class_name OrbOnLandState

@export var poison_duration: float = 4.0

func enter() -> void:
	orb.velocity = Vector2.ZERO
	# 强制归零旋转角度，防止毒水贴图在地上是歪的
	orb.rotation = 0.0 
	
	orb.animation_player.play("on_land")
	
	var timer = Timer.new()
	timer.wait_time = poison_duration
	timer.one_shot = true
	timer.timeout.connect(func(): switched_to.emit(self, "end"))
	add_child(timer)
	timer.start()

func take_physics_process(delta: float) -> void:
	# 保持在地面，应用微小重力防止悬空
	orb.velocity.y += orb.gravity * delta
	orb.move_and_slide()