extends StateBase
class_name PlayerState

@export var player: Player

func take_unhandled_input(event: InputEvent) -> void:
	if player.health_component.is_dead:
		return 
		
	if event.is_action_pressed("Key_W") and player.stats_component.enable_jump:
		player.jump_request_timer.start()
		
	if event.is_action_pressed("Interact"):
		EventBus.interact_request.emit(player)

func take_physics_process(delta: float) -> void:
	if player.health_component.is_dead:
		return 
		
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	var direction := Input.get_axis("Key_A", "Key_D")
	if direction and player.stats_component.enable_move:
		player.velocity.x = move_toward(player.velocity.x, direction * player.stats_component.current_speed, player.stats_component.current_accelerate * delta)
		player.stats_component.facing_left = (direction == -1)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.stats_component.current_accelerate * delta)

	if player.velocity.x != 0:
		player.sprite_2d.flip_h = player.stats_component.facing_left

	player.velocity += player.stats_component.get_force()
	player.move_and_slide()