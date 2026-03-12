extends DroneState 
class_name DroneDieState

func enter() -> void:
	drone.animation_player.play("die")
	drone.sprite_2d.material.set_shader_parameter("hit", false)
	drone.sprite_2d.material.set_shader_parameter("outline_size", 0.0)
	
	# 命令挂载的 Cannon 一起陪葬
	if is_instance_valid(drone.cannon) and drone.cannon.state_machine:
		drone.cannon.state_machine.switch_to("die")
		
	if drone.hurt_box:
		drone.hurt_box.queue_free()
	if drone.hit_box:
		drone.hit_box.queue_free()
		
	# 开启物理重力，让无人机播放死亡动画时坠落！
	# drone.velocity 
	drone.has_gravity = true
	
	# 等待死亡动画结束再销毁
	await drone.animation_player.animation_finished
	drone.queue_free()

func exit() -> void:
	pass

func take_input(event: InputEvent) -> void:
	super.take_input(event)

func take_unhandled_input(event: InputEvent) -> void:
	super.take_unhandled_input(event)

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta : float) -> void:
	super.take_process(delta)