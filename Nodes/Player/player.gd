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
	
	# --- 修复：精力自动恢复的计时器连线 ---
	if recovery_stamina_timer:
		recovery_stamina_timer.timeout.connect(_on_recovery_stamina_timeout)
	
	# 通知 UIManager 玩家已就绪，并把组件引用全交出去
	EventBus.player_components_ready.emit(health_component, stats_component, inventory_component, skill_component)

func _process(delta: float) -> void:
	stats_component.fire_facing_left = (rune_emitter.sprites.global_rotation_degrees >= -90.0 
										and rune_emitter.sprites.global_rotation_degrees < 90.0)

# --- 修复：把被我吞掉的输入控制全部加回来 ---
func _input(event: InputEvent) -> void:
	if health_component.is_dead:
		return 
	if event.is_action_pressed("OpenInventoryUI"):
		# 注意：因为我们前面在 UIManager 里已经缓存了玩家组件，
		# 这里不需要再把 inventory_component 作为参数传过去了，直接 emit 即可打开。
		UIManager.inventory_ui_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	if health_component.is_dead:
		return 
	var triggered_skill_data : SkillData = skill_component.check_skills_triggered()
	if triggered_skill_data != null:
		rune_emitter.fire(triggered_skill_data)

# --- 战斗与状态逻辑 ---
func _on_took_damage(amount: int) -> void:
	if health_component.is_dead:
		return

	sprite_2d.material.set_shader_parameter("hit", true)
	EventBus.camera_shake.emit(Vector2(10.0, 10.0), 0.3)
	on_hit.emit(true)
	hit_sfx.play()
	
	hurt_box.is_invincible = true
	hurt_box.set_deferred("monitorable", false)

func _on_player_died() -> void:
	state_machine.switch_to("die")

# --- 修复：精力的具体恢复逻辑 ---
func _on_recovery_stamina_timeout() -> void:
	if not health_component.is_dead:
		# 每次计时器结束，恢复 1 点精力（你可以根据实际设计修改数值）
		stats_component.recover_stamina(1)