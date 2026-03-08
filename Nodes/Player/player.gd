class_name Player
extends CharacterBody2D

signal on_hit(flag : bool)

var skill_component: SkillComponent = GameInstance.skill_component
var status_component: StatusComponent = GameInstance.status_component
var inventory_component: InventoryComponent = GameInstance.inventory_component
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rune_emitter: RuneEmitter = %RuneEmitter
@onready var hit_box: Area2D = %HitBox
@onready var state_machine: StateMachine = $StateMachine
var jump_request_timer : Timer = Timer.new()
var coyote_timer : Timer = Timer.new()
#@onready var run_sfx: AudioStreamPlayer = %run_sfx
@onready var hit_sfx: AudioStreamPlayer = $hit_sfx

var last_on_floor_position : Vector2

@onready var recovery_stamina_timer: Timer = %RecoveryStaminaTimer

func is_point_colliding(point: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state

	var params := PhysicsPointQueryParameters2D.new()
	params.position = point
	# params.collide_with_areas = true
	params.collide_with_bodies = true
	# params.collision_mask = (1 << 5)

	var result = space_state.intersect_point(params)

	return result.size() > 0


func _ready() -> void:
	
	skill_component= GameInstance.skill_component
	status_component = GameInstance.status_component
	inventory_component= GameInstance.inventory_component
	# status_component._current_stamina = status_component.stamina
	
	skill_component.skill_owner = self
	

	if status_component.is_die:
		status_component.is_die = false
		status_component.recover_hp(status_component.hp)


		
	
	jump_request_timer.wait_time = 0.24
	jump_request_timer.one_shot = true
	add_child(jump_request_timer)

	coyote_timer.wait_time = 0.1
	coyote_timer.one_shot = true
	add_child(coyote_timer)

	EventBus.enter_scene.connect(_enter_scene)

	EventBus.stamina_upper_limit_increased.connect(func(val : int) :
		status_component.increase_max_stamina(val)
	)
	EventBus.health_upper_limit_increased.connect(func(val : int) :
		status_component.increase_max_hp(val)
	)

	rune_emitter.visible = status_component.has_emitter

	recovery_stamina_timer.wait_time = status_component.stamina_recovery_time

	UIManager.state_ui_request.emit(status_component)

	EventBus.player_teleport_request.connect(func(teleport_position : Vector2) -> void:
		state_machine.switch_to("teleport")
		if !is_point_colliding(teleport_position):
			global_position = teleport_position
		
	)



func _on_recovery_stamina_timer_timeout() -> void:
	status_component.recover_stamina(1)


func _exit_tree() -> void:
	EventBus.enter_scene.disconnect(_enter_scene)


func equip_emitter():
	status_component.has_emitter = true
	rune_emitter.visible = true

func add_runes(rune_list : Array[RuneData]):
	inventory_component.add_runes(rune_list)

func add_skills(skill_list : Array[SkillData]):
	inventory_component.add_skills(skill_list)

func _enter_scene(param : Dictionary) -> void:
	if param.has("enter_point"):
		# print("get enter_point")
		var enter_point : EnterPoint = param["enter_point"]
		global_position = enter_point.global_position
	#else:
		#print("no nono")

func _input(event: InputEvent) -> void:
	if status_component.is_die:
		return 
	if event.is_action_pressed("OpenInventoryUI"):
		UIManager.inventory_ui_requested.emit(inventory_component)
	

func _unhandled_input(event: InputEvent) -> void:
	if status_component.is_die:
		return 
	var triggered_skill_data : SkillData = skill_component.check_skills_triggered()
	if triggered_skill_data != null:
		rune_emitter.fire(triggered_skill_data)
		

func _physics_process(delta: float) -> void:
	pass
	# if not is_on_floor():
		# velocity += get_gravity() * delta

	# if Input.is_action_pressed("Key_W") and is_on_floor():
		# velocity.y = status_component.jump_speed

	# var direction := Input.get_axis("Key_A", "Key_D")
	# if direction:
	# 	velocity.x = direction * status_component.speed
	# 	status_component.facing_direction = direction * Vector2.RIGHT
	# else:
	# 	velocity.x = move_toward(velocity.x, 0, status_component.speed)
	

func _process(delta: float) -> void:
	status_component.fire_facing_left = (rune_emitter.sprites.global_rotation_degrees >= -90.0 
										and rune_emitter.sprites.global_rotation_degrees < 90.0)
	#print(rune_emitter.sprites.global_rotation_degrees)


# const Hit_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

var is_switch_die_state : bool = false


func _on_hit_box_area_entered(area: HurtBox) -> void:
	if status_component.is_die:
		return

	sprite_2d.material.set_shader_parameter("hit", true)
	status_component.decrease_hp(area.damage)
	EventBus.camera_shake.emit(Vector2(10.0, 10.0), 0.3)
	on_hit.emit(true)
	hit_sfx.play()
	hit_box.set_collision_mask_value(3,false)


	if status_component.is_die and !is_switch_die_state:
		is_switch_die_state = true
		state_machine.switch_to("die")
		EventBus.player_die.emit()

	await get_tree().create_timer(1.5).timeout

	hit_box.set_collision_mask_value(3,true)
	on_hit.emit(false)
	sprite_2d.material.set_shader_parameter("hit", false)

	if status_component.is_die and !is_switch_die_state:
		is_switch_die_state = true
		state_machine.switch_to("die")
		# status_component.recover_hp(status_component.hp)
		

	
	
