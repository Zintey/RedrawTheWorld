@tool
extends EnemyBase
class_name L4

@export_category("L4 Settings")
@export var idle_speed: float = 40.0
@export var dash_speed: float = 150.0
@export var safe_distance: float = 150.0 
@export var flight_time: float = 0.8 # 毒球强制落地时间（越小飞得越快）

@onready var warn_area: Area2D = %WarnArea
@onready var floor_ray_cast_l: RayCast2D = %FloorRayCastL
@onready var floor_ray_cast_r: RayCast2D = %FloorRayCastR
@onready var fire_point: Node2D = %FirePoint

@onready var hit_box: HitBox = $HitBox
const POISON_ORB_SCENE = preload("uid://pssblhuk8dch")

func _ready() -> void:
	super._ready()
	if warn_area:
		warn_area.body_entered.connect(_on_warn_area_entered)

func _on_warn_area_entered(body: Node2D) -> void:
	if body is Player:
		# 我们暂不使用射线遮挡，直接锁定玩家
		target_body = body

func check_left_floor() -> bool:
	return floor_ray_cast_l.is_colliding()

func check_right_floor() -> bool:
	return floor_ray_cast_r.is_colliding()

func fire_poison_orb() -> void:
	if not is_instance_valid(target_body):
		return
	
	var orb: PoisonOrb = POISON_ORB_SCENE.instantiate()
	get_tree().current_scene.add_child(orb)
	orb.global_position = fire_point.global_position
	
	# --- 提取出真实的“枪管方向” ---
	# (只要你把 FirePoint 节点放在了枪口，这个方向就是绝对正确的)
	var dir = fire_point.global_position - global_position
	if dir.length() < 1.0: # 防呆兜底
		dir = Vector2.RIGHT.rotated(global_rotation)
		
	# 让毒球本身的贴图也顺着枪管转过去（如果有的话）
	orb.global_rotation = dir.angle() 
	
	# 调用发射：传目标、传方向、传时间
	orb.launch(target_body.global_position + Vector2(0, -15), dir, flight_time)
	
 