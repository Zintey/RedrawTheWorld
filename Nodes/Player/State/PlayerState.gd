extends StateBase
class_name PlayerState

@export var player : Player

func take_unhandled_input(event: InputEvent) -> void:
	if player.status_component.is_die:
		return 
	if event.is_action_pressed("Key_W") and player.status_component.enable_jump:
		player.jump_request_timer.start()
	if event.is_action_pressed("Interact"):
		
		EventBus.interact_request.emit(player)

func take_physics_process(delta: float) -> void:
	if player.status_component.is_die:
		return 
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	var direction := Input.get_axis("Key_A", "Key_D")
	if direction and player.status_component.enable_move:
		player.velocity.x = move_toward(player.velocity.x, direction * player.status_component.current_speed, player.status_component.current_accelerate * delta)
		player.status_component.facing_left = (direction == -1)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.status_component.current_accelerate * delta)

	if player.velocity.x != 0:
		player.sprite_2d.flip_h = player.status_component.facing_left

	player.velocity += player.status_component.get_force()
	player.move_and_slide()
