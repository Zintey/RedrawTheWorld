class_name Player
extends CharacterBody2D

signal on_hit(flag: bool)

@export var hit_sfx : AudioEvent

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
@onready var hurt_collision_shape: CollisionShape2D = %HurtCollisionShape

var jump_request_timer: Timer = Timer.new()
var coyote_timer: Timer = Timer.new()

var last_on_floor_position: Vector2
@onready var recovery_stamina_timer: Timer = %RecoveryStaminaTimer

func _ready() -> void:
	
	add_child(jump_request_timer)
	jump_request_timer.one_shot = true
	jump_request_timer.wait_time = 0.2
	
	add_child(coyote_timer)
	coyote_timer.one_shot = true
	coyote_timer.wait_time = 0.1
	
	hurt_box.took_damage.connect(_on_took_damage)
	health_component.died.connect(_on_player_died)
	
	if recovery_stamina_timer:
		recovery_stamina_timer.timeout.connect(_on_recovery_stamina_timeout)
		
	EventBus.player_teleport_request.connect(_on_player_teleport_request)
	EventBus.health_upper_limit_increased.connect(func(val): health_component.max_hp += val; health_component.recover_hp(val))
	EventBus.stamina_upper_limit_increased.connect(func(val): stats_component.max_stamina += val; stats_component.recover_stamina(val))
	
	EventBus.player_components_ready.emit(health_component, stats_component, inventory_component, skill_component)

	EventBus.emit_rune_signalA.connect(func ():
		skill_component.post_event("SIGNALA", 0.2)
	)

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
		
	# 【新增】：按下S键，直接触发下落穿透单向平台
	if event.is_action_pressed("Key_S") and is_on_floor():
		drop_through_platform()
		
	# 【修改】：不再直接检查技能，而是向黑板发送 0.1秒(手感最佳)的缓冲事件
	if event.is_action_pressed("LMB"):
		skill_component.post_event("LMB", 0.1)
	elif event.is_action_pressed("RMB"):
		skill_component.post_event("RMB", 0.1)
	elif event.is_action_pressed("Key_Space"):
		skill_component.post_event("SPACE", 0.1)
	
	if event.is_action_pressed("Debug_Key_T"):
		print("测试：玩家发起换层请求！")
		# 传入 false，代表这不是刚开局，而是中途切层
		EventBus.level_transition_started.emit(false)

# --- 平台互动逻辑 ---
# 【新增】：处理从单向平台漏下去的逻辑
func drop_through_platform() -> void:
	# 临时关闭玩家对第 7 层（单向平台层）的碰撞检测
	set_collision_mask_value(7, false)
	
	# 等待 0.2 秒，让重力把玩家拉下去
	await get_tree().create_timer(0.2).timeout
	
	# 恢复对第 7 层的碰撞检测（加个节点是否还在树上的判断，防止等待期间玩家被销毁报错）
	if is_inside_tree():
		set_collision_mask_value(7, true)


# --- 战斗、状态与事件响应逻辑 ---
func _on_took_damage(amount: int) -> void:
	if health_component.is_dead:
		return

	# 【新增】：受击时向黑板发送 0.5秒 的状态便签，供技能读取
	skill_component.post_event("took_damage", 0.5)

	sprite_2d.material.set_shader_parameter("hit", true)
	EventBus.camera_shake.emit(Vector2(10.0, 10.0), 0.3)
	on_hit.emit(true)
	AudioManager.play_sfx(hit_sfx)
	
	# 【恢复】：开启无敌与碰撞体禁用
	hurt_box.is_invincible = true
	hurt_collision_shape.disabled = true
	hurt_box.set_deferred("monitorable", false)
	
	# 【恢复】：0.8秒后的无敌帧结束与表现重置
	var recover_timer = get_tree().create_timer(0.8)
	recover_timer.timeout.connect(func():
		if is_instance_valid(sprite_2d):
			sprite_2d.material.set_shader_parameter("hit", false)
		if is_instance_valid(hurt_box):
			hurt_box.is_invincible = false
			hurt_collision_shape.disabled = false
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

func play_sfx(sfx : AudioEvent) -> void:
	AudioManager.play_sfx(sfx)