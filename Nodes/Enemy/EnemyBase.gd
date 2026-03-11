extends CharacterBody2D
class_name EnemyBase

## 房间系统监听这个信号来判断是否开门
signal died(enemy_node: Node)

# --- 统一节点引用 (要求子场景必须有这些 % 唯一节点或同名节点) ---
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurt_box: HurtBox = %HurtBox
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var state_machine: StateMachine = %StateMachine
@onready var center_point: Node2D = %CenterPoint

# --- 基础物理配置 ---
@export var has_gravity: bool = true
@export var is_summoned: bool = false # 预留给 Boss 召唤物

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- 统一方向控制系统 ---
enum Direction { Left = -1, Right = 1 }
@export var move_direction: Direction = Direction.Right

# --- 统一目标追踪 ---
var target_body: Node2D = null

func _ready() -> void:
	# 确保怪物被加入了 Enemy 组，配合 Spawner 和 房间系统
	add_to_group("Enemy")
	
	# 自动接管战斗信号
	if health_component:
		health_component.died.connect(_on_died)
	if hurt_box:
		hurt_box.took_damage.connect(_on_took_damage)

func _physics_process(delta: float) -> void:
	# 基类自动处理重力，飞行怪 (Drone) 只要把 has_gravity 设为 false 就不受影响
	if has_gravity and not is_on_floor():
		velocity.y += gravity * delta

# --- 统一战斗响应逻辑 ---
func _on_took_damage(amount: int) -> void:
	if health_component.is_dead:
		return
	
	# 挨打统一进 hit 状态（具体的闪烁和减速效果，交由怪物的 HitState 去写）
	if state_machine and state_machine.current_state.name != "die":
		state_machine.switch_to("hit")
		print("switch to hit")

func _on_died() -> void:
	# 死亡时自动移除标签，并通知房间
	remove_from_group("Enemy")
	died.emit(self)
	
	if state_machine:
		state_machine.switch_to("die")

# --- 统一翻转逻辑 (白嫖代码，再也不用每个怪写一遍) ---
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