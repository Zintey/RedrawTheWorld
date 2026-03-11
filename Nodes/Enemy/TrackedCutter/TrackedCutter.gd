@tool
extends EnemyBase
class_name TrackedCutter

@export var idle_speed : float = 30.0
@export var follow_speed : float = 80.0
@export var attack2_speed : float = 180.0
@export var attack1_speed : float = 20.0
var current_speed : float = idle_speed

@onready var forward_ray_cast: RayCast2D = %ForwardRayCast
@onready var floor_ray_cast_l: RayCast2D = %FloorRayCastL
@onready var floor_ray_cast_r: RayCast2D = %FloorRayCastR
@onready var attack_1ray_cast: RayCast2D = %Attack1RayCast
@onready var attack_2ray_cast: RayCast2D = %Attack2RayCast
@onready var player_ray_cast: RayCast2D = %FollowRayCast
@onready var attack_interval_timer: Timer = %AttackIntervalTimer

# 【修复】：明确获取负责打人的 HitBox
@onready var hit_box: HitBox = %HitBox 

func check_find_player() -> bool:
	if player_ray_cast.is_colliding():
		var collider = player_ray_cast.get_collider()
		if collider is Player:
			target_body = collider
			return true
	return false

func check_lose_player() -> bool:
	return !player_ray_cast.is_colliding()

func check_can_forward() -> bool:
	return !(forward_ray_cast.is_colliding())

func check_left_floor() -> bool:
	return floor_ray_cast_l.is_colliding()

func check_right_floor() -> bool:
	return floor_ray_cast_r.is_colliding()

func check_player_in_attack1_area() -> bool:
	return attack_1ray_cast.is_colliding()

func check_player_in_attack2_area() -> bool:
	return attack_2ray_cast.is_colliding()
