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

# 统一方向控制系统
enum Direction { Left = -1, Right = 1 }
@export var move_direction: Direction = Direction.Right

# 真正的锁定目标
var target_body: Node2D = null
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

func _on_took_damage(amount: int) -> void:
	if health_component.is_dead:
		return
	if state_machine and state_machine.current_state.name != "die":
		state_machine.switch_to("hit")

func _on_died() -> void:
	remove_from_group("Enemy")
	died.emit(self)
	set_outline(false)
	if state_machine:
		state_machine.switch_to("die")

# --- 视线射线检测逻辑 (超级 Debug 版) ---
func check_line_of_sight(target: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var start_pos = center_point.global_position if center_point else global_position + Vector2(0, -10)
	var end_pos = target.global_position + Vector2(0, -10)
	
	var query = PhysicsRayQueryParameters2D.create(start_pos, end_pos)
	
	# 【排雷 1】：排除怪物自己！防止射线一出门就打在自己脸上被挡住
	query.exclude = [self.get_rid()] 
	
	# 【排雷 2】：开启全图扫描！检测所有层 (全为1的二进制)，并且包括 Area2D
	query.collision_mask = 4294967295 
	query.collide_with_areas = true 
	
	var result = space_state.intersect_ray(query)
	
	# print("==================================")
	# print("📡 [视线测试] ", self.name, " 正在看向 -> ", target.name)
	# print("起点: ", start_pos, " | 终点: ", end_pos)
	
	if result.is_empty():
		# print("✅ 结果：畅通无阻！什么都没撞到。")
		return true 
	else:
		var hit_obj = result.collider
		# var hit_name = hit_obj.name if hit_obj else "未知节点"
		# var hit_class = hit_obj.get_class() if hit_obj else "未知类"
		
		var hit_layer = "未知"
		if hit_obj is CollisionObject2D:
			hit_layer = str(hit_obj.collision_layer)
			
		# print("❌ 结果：被挡住了！挡路者是 -> 名字: [", hit_name, "] | 类型: [", hit_class, "] | 碰撞层 Layer: [", hit_layer, "]")
		
		# 如果撞到的刚好是玩家本人，或者玩家身上的 HurtBox (它的 owner 是玩家)
		if hit_obj == target or (hit_obj.owner and hit_obj.owner == target):
			# print("🎯 结论：这个挡路者就是玩家自己！视线确认连通！")
			return true
		
		# print("🧱 结论：这是真正的障碍物，视线中断！")
		return false

# --- 统一视野与描边 API ---
func acquire_target(body: Node2D) -> void:
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