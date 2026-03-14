@tool
extends EnemyBase
class_name Cannon

@export var rotate_speed : float = 1.5
var current_rotate_speed : float = 0.0

var target_position : Vector2 = Vector2.ZERO
var on_follow : bool = false

@onready var turn_right_cast_d: RayCast2D = %TurnRightCastD
@onready var turn_right_cast_u: RayCast2D = %TurnRightCastU
@onready var turn_left_cast_d: RayCast2D = %TurnLeftCastD
@onready var turn_left_cast_u: RayCast2D = %TurnLeftCastU
@onready var warn_area: Area2D = %WarnArea
@onready var fire_point: Node2D = %FirePoint

# 独有的旋转方向枚举（区别于基类的水平移动 move_direction）
enum RotateDirection { Left = -1, Stop = 0, Right = 1 }
var rotate_direction : RotateDirection = RotateDirection.Stop

func _ready() -> void:
	super._ready()
	# 炮台不受重力影响
	has_gravity = false
	
	# 【修复】：补上监听玩家进入/离开区域的逻辑
	if warn_area:
		warn_area.body_entered.connect(_on_warn_area_body_entered)
		warn_area.body_exited.connect(_on_warn_area_body_exited)

func check_can_turn_left() -> bool:
	return !(turn_left_cast_d.is_colliding() or turn_left_cast_u.is_colliding())

func check_can_turn_right() -> bool:
	return !(turn_right_cast_d.is_colliding() or turn_right_cast_u.is_colliding())

func check_is_warning() -> bool:
	return target_body != null

func check_lose_warning() -> bool:
	return target_body == null


func _on_warn_area_body_entered(body: Node2D) -> void:
	if body is Player:
		acquire_target(body) # <--- 自动触发红边、打断遗忘计时

func _on_warn_area_body_exited(body: Node2D) -> void:
	lose_target(body) # <--- 自动开启遗忘倒计时，时间到了才会解除红边并丢失目标

func rotate_left() -> void:
	rotate_direction = RotateDirection.Left
	current_rotate_speed = 0.0

func rotate_right() -> void:
	rotate_direction = RotateDirection.Right
	current_rotate_speed = 0.0

func rotate_stop() -> void:
	rotate_direction = RotateDirection.Stop
	current_rotate_speed = 0.0

func check_turn_to_target() -> bool:
	return abs(global_rotation - (target_position - global_position).normalized().angle()) <= 0.1

const Fire_Bullet = preload("res://Nodes/Enemy/Cannon/FireButton/cannon_fire_button.tscn")

func fire(button_size : float = 1.0) -> void:
	var fire_button :Node2D = Fire_Bullet.instantiate()
	fire_button.global_rotation = fire_point.global_rotation
	fire_button.global_position = fire_point.global_position
	fire_button.global_scale *= button_size
	get_tree().current_scene.add_child(fire_button)