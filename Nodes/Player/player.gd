class_name Player
extends CharacterBody2D

signal on_hit(flag: bool)

# --- 本地组件引用 ---
@onready var health_component: HealthComponent = $HealthComponent
@onready var stats_component: PlayerStatsComponent = $PlayerStatsComponent
@onready var inventory_component: InventoryComponent = $InventoryComponent
@onready var skill_component: SkillComponent = $SkillComponent

@onready var hurt_box: HurtBox = %HurtBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rune_emitter: RuneEmitter = %RuneEmitter
@onready var state_machine: StateMachine = $StateMachine

var jump_request_timer: Timer = Timer.new()
var coyote_timer: Timer = Timer.new()
@onready var hit_sfx: AudioStreamPlayer = $hit_sfx

var last_on_floor_position: Vector2
@onready var recovery_stamina_timer: Timer = %RecoveryStaminaTimer

func _ready() -> void:
	add_child(jump_request_timer)
	jump_request_timer.one_shot = true
	
	add_child(coyote_timer)
	coyote_timer.one_shot = true
	
	hurt_box.took_damage.connect(_on_took_damage)
	health_component.died.connect(_on_player_died)
	
	if recovery_stamina_timer:
		recovery_stamina_timer.timeout.connect(_on_recovery_stamina_timeout)
		
	# --- 修复：把被删掉的传送和属性成长信号监听加回来！ ---
	EventBus.player_teleport_request.connect(_on_player_teleport_request)
	EventBus.health_upper_limit_increased.connect(func(val): health_component.max_hp += val; health_component.recover_hp(val))
	EventBus.stamina_upper_limit_increased.connect(func(val): stats_component.max_stamina += val; stats_component.recover_stamina(val))
	
	# 通知 UIManager 玩家已就绪，并把组件引用全交出去
	EventBus.player_components_ready.emit(health_component, stats_component, inventory_component, skill_component)

func _process(delta: float) -> void:
	stats_component.fire_facing_left = (rune_emitter.sprites.global_rotation_degrees >= -90.0 
										and rune_emitter.sprites.global_rotation_degrees < 90.0)

# --- 输入控制 ---
func _input(event: InputEvent) -> void:
	if health_component.is_dead:
		return 
	if event.is_action_pressed("OpenInventoryUI"):
		UIManager.inventory_ui_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	if health_component.is_dead:
		return 
	var triggered_skill_data : SkillData = skill_component.check_skills_triggered()
	if triggered_skill_data != null:
		rune_emitter.fire(triggered_skill_data)

# --- 战斗、状态与事件响应逻辑 ---
func _on_took_damage(amount: int) -> void:
	if health_component.is_dead:
		return

	sprite_2d.material.set_shader_parameter("hit", true)
	EventBus.camera_shake.emit(Vector2(10.0, 10.0), 0.3)
	on_hit.emit(true)
	hit_sfx.play()
	
	hurt_box.is_invincible = true
	hurt_box.set_deferred("monitorable", false)
	
	var recover_timer = get_tree().create_timer(0.8)
	recover_timer.timeout.connect(func():
		if is_instance_valid(sprite_2d):
			sprite_2d.material.set_shader_parameter("hit", false)
		if is_instance_valid(hurt_box):
			hurt_box.is_invincible = false
			on_hit.emit(false)
			hurt_box.set_deferred("monitorable", true)
	)

func _on_player_died() -> void:
	state_machine.switch_to("die")

# --- 传送机制 ---
func _on_player_teleport_request(teleport_position: Vector2) -> void:
	if health_component.is_dead:
		return
	# 改变坐标，并切入你的传送状态（PlayerTeleportState）
	global_position = teleport_position
	state_machine.switch_to("teleport")

# --- 精力恢复逻辑 ---
func _on_recovery_stamina_timeout() -> void:
	if not health_component.is_dead:
		stats_component.recover_stamina(1)
