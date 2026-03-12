@tool
extends EnemyBase
class_name Drone

@export var patrol_range : float = 250.0

var current_move_speed : float
var current_move_direction : Vector2

var in_obstacle : bool = false

@onready var cannon: Cannon = %Cannon
@onready var hit_box: HitBox = %HitBox
@onready var warn_area: Area2D = $WarnArea

func _ready() -> void:
	super._ready() # <--- 就是缺了这一句致命的代码！！！
	has_gravity = false
	
	# 下面保留你之前加的检测玩家的代码
	if warn_area:
		warn_area.body_entered.connect(func(body: Node2D): 
			if body is Player: target_body = body
		)
		warn_area.body_exited.connect(func(body: Node2D): 
			if body == target_body: target_body = null
		)

func _physics_process(delta: float) -> void:
	super._physics_process(delta) # 保持基类的重力逻辑
	
	# 【修复】：让无人机共享炮台的视野
	if is_instance_valid(cannon):
		target_body = cannon.target_body

func check_can_move() -> bool:
	return !in_obstacle

func check_is_warn() -> bool:
	return target_body != null

func check_lose_target() -> bool:
	return target_body == null

# check_on_hit() 和 check_is_die() 等受击判断已被 EnemyBase 完美接管并删除！