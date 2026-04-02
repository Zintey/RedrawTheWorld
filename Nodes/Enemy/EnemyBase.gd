extends CharacterBody2D
class_name EnemyBase

signal died(enemy_node: Node)

# --- 统一节点引用 ---
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurt_box: HurtBox = %HurtBox
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var state_machine: StateMachine = %StateMachine
@onready var center_point: Node2D = %CenterPoint

# --- 基础配置 ---
@export_category("Enemy Base Settings")
@export var has_gravity: bool = true
@export var is_summoned: bool = false

# --- 视野与记忆配置 ---
@export_category("Vision Settings")
@export var lose_target_delay: float = 2.0 ## 玩家离开视线后，保持追踪的记忆时间（秒）。设为 -1 代表死咬不放。

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var lose_target_timer: Timer

var die_flag: bool = false

# 统一方向控制系统
enum Direction { Left = -1, Right = 1 }
@export var move_direction: Direction = Direction.Right

# 真正的锁定目标
var target_body: Node2D = null:
	set(target):
		if die_flag:
			target = null
		else:
			target_body = target
# 只是进入了圆形区域，但还需要经过射线验证的“嫌疑目标”
var player_in_range: Node2D = null

func _ready() -> void:
	add_to_group("Enemy")
	
	if health_component:
		health_component.died.connect(_on_died)
	if hurt_box:
		hurt_box.took_damage.connect(_on_took_damage)
		
	lose_target_timer = Timer.new()
	lose_target_timer.one_shot = true
	lose_target_timer.timeout.connect(_on_lose_target_timeout)
	add_child(lose_target_timer)

func _physics_process(delta: float) -> void:
	if has_gravity and not is_on_floor():
		velocity.y += gravity * delta
	# --- 视线(RayCast)遮挡自动检测 ---
	if is_instance_valid(player_in_range):
		if check_line_of_sight(player_in_range):
			# 视线无遮挡：如果还没锁定，或者正在遗忘倒数，立刻锁定！
			if target_body != player_in_range or not lose_target_timer.is_stopped():
				acquire_target(player_in_range)
		else:
			# 视线被墙挡住：如果当前锁定了玩家，当作丢失视野处理（开始遗忘倒数）
			if target_body == player_in_range and lose_target_timer.is_stopped():
				lose_target(player_in_range)

func _on_took_damage(amount: float, knockback_force : Vector2) -> void:
	if health_component.is_dead:
		return
	if state_machine and state_machine.current_state.name != "die":
		state_machine.switch_to("hit")
		var mat = sprite_2d.material as ShaderMaterial
		if mat: mat.set_shader_parameter("hit", true)
		get_tree().create_timer(0.08).timeout.connect(func(): if mat: mat.set_shader_parameter("hit", false))

func _on_died() -> void:
	remove_from_group("Enemy")
	died.emit(self)
	set_outline(false)
	die_flag = true
	target_body = null
	if state_machine:
		state_machine.switch_to("die")

# --- 视线射线检测逻辑 (终极纯净版：只测墙壁，无视一切生物与区域) ---
func check_line_of_sight(target: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var start_pos = center_point.global_position if center_point else global_position + Vector2(0, -10)
	var end_pos = target.global_position + Vector2(0, -10)
	
	var query = PhysicsRayQueryParameters2D.create(start_pos, end_pos)
	
	# 排除自己 (以防万一未来你把怪物本体也放进了地形层)
	query.exclude = [self.get_rid()] 
	
	# 【核心机制 1】：坚决关闭 Area2D 碰撞检测！
	# 这能让射线瞬间穿透所有敌人的 HitBox、HurtBox 以及你画的巨型雷达圈 WarnArea。
	query.collide_with_areas = false 
	
	# 【核心机制 2】：精准定轨 Layer 6 (地形层)
	# 第 6 层的值是 32。这根射线现在是个绝对的“透视眼”，只对墙壁和地板起反应。
	query.collision_mask = 32 
	
	var result = space_state.intersect_ray(query)
	
	# 【极致精简的逻辑】：
	# 因为射线只会撞墙，所以：
	# 结果为空 (is_empty) -> 中间没墙 -> 视野畅通无阻 (返回 true)
	# 结果不为空 -> 撞到墙了 -> 视野被遮挡 (返回 false)
	return result.is_empty()

# --- 统一视野与描边 API ---
func acquire_target(body: Node2D) -> void:
	if die_flag: return
	target_body = body
	player_in_range = body
	if not lose_target_timer.is_stopped():
		lose_target_timer.stop()
	set_outline(true)

func lose_target(body: Node2D) -> void:
	if body == target_body:
		if lose_target_delay > 0:
			lose_target_timer.start(lose_target_delay)
		elif lose_target_delay == 0:
			_on_lose_target_timeout()
		# 如果 lose_target_delay < 0，什么都不做，永远不遗忘（给自爆怪用）

func _on_lose_target_timeout() -> void:
	target_body = null
	set_outline(false)

func set_outline(active: bool) -> void:
	if is_instance_valid(sprite_2d) and sprite_2d.material:
		if active:
			sprite_2d.material.set_shader_parameter("outline_size", 1.0)
			sprite_2d.material.set_shader_parameter("outline_color", Color(1.0, 0.0, 0.0, 1.0))
		else:
			sprite_2d.material.set_shader_parameter("outline_size", 0.0)

# --- 统一翻转逻辑 (省略中间相同代码，保持你原来的即可) ---
func turn_left() -> void:
	move_direction = Direction.Left
	if center_point:
		center_point.scale.x = -1.0

func turn_right() -> void:
	move_direction = Direction.Right
	if center_point:
		center_point.scale.x = 1.0

func turn_back() -> void:
	if move_direction == Direction.Left:
		turn_right()
	else:
		turn_left()

func flip_towards(target_pos: Vector2) -> void:
	if target_pos.x > global_position.x:
		turn_right()
	elif target_pos.x < global_position.x:
		turn_left()

func has_target() -> bool:
	return target_body != null

func play_sfx(sfx : AudioEvent) -> void:
	AudioManager.play_sfx(sfx)
