class_name PlayerStatsComponent extends Node

signal stamina_changed(current_stamina: int, max_stamina: int)

@export var max_stamina: int = 6

@export var current_gold: int = 500

var current_stamina: int

# @export var max_mp: int = 10
# var current_mp: int

# --- 移动与控制参数 ---
var walk_speed: float = 200.0
var run_speed: float = 300.0
var current_speed: float = walk_speed

var floor_accelerate: float = run_speed / 0.2
var air_accelerate: float = floor_accelerate * 2.0
var current_accelerate: float = floor_accelerate

var jump_speed : float = -1000.0

var enable_move: bool = true
var enable_jump: bool = true
var can_jump: bool = true
var facing_left: bool = false
var fire_facing_left: bool = false
var has_emitter: bool = true

# --- 外力系统 (如符文的后坐力) ---
var _push_force: Vector2 = Vector2.ZERO

func _ready() -> void:
	current_stamina = max_stamina
	# current_mp = max_mp

func reduce_stamina(amount: int) -> void:
	current_stamina = max(current_stamina - amount, 0)
	stamina_changed.emit(current_stamina, max_stamina)

func recover_stamina(amount: int) -> void:
	current_stamina = min(current_stamina + amount, max_stamina)
	stamina_changed.emit(current_stamina, max_stamina)

func add_force(force: Vector2) -> void:
	_push_force += force

func get_force() -> Vector2:
	var force = _push_force
	_push_force = Vector2.ZERO
	return force


# 扣钱函数
func spend_gold(amount: int) -> bool:
	if current_gold >= amount:
		current_gold -= amount
		# EventBus.player_gold_changed.emit(current_gold) # 如果有UI可以发信号刷新
		return true
	return false