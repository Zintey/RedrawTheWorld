@tool
extends CharacterBody2D
class_name TrackedCutter


signal die_signal()

# var hit_position : Vector2 = Vector2.ZERO

# func _ready() -> void:
# 	var data : Dictionary = SceneManager.load_data_by_UID(self.name)
# 	if data.has("is_die"):
# 		status_component.on_hit = data["is_die"]
# 		status_component.is_die = data["is_die"]

# func _exit_tree() -> void:
# 	var data : Dictionary = {
# 		"is_die" : status_component.is_die
# 	}
# 	SceneManager.save_data_by_UID(self.name, data)

@export var idle_speed : float = 30.0
@export var follow_speed : float = 80.0
@export var attack2_speed : float = 180.0
@export var attack1_speed : float = 20.0
var current_speed : float = idle_speed

@onready var center_point: Node2D = %CenterPoint
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var forward_ray_cast: RayCast2D = %ForwardRayCast
@onready var floor_ray_cast_l: RayCast2D = %FloorRayCastL
@onready var floor_ray_cast_r: RayCast2D = %FloorRayCastR
@onready var attack_1ray_cast: RayCast2D = %Attack1RayCast
@onready var attack_2ray_cast: RayCast2D = %Attack2RayCast
@onready var follow_ray_cast: RayCast2D = %FollowRayCast
@onready var un_follow_ray_cast: RayCast2D = %UnFollowRayCast

@onready var state_machine: StateMachine = $StateMachine

@onready var hit_box: HitBox = %HitBox
@onready var hurt_box: HurtBox = %HurtBox

@onready var attack_interval_timer: Timer = %AttackIntervalTimer

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var status_component: StatusComponent = %StatusComponent

func check_find_player() -> bool:
	return follow_ray_cast.is_colliding()
func check_lose_player() -> bool:
	return !un_follow_ray_cast.is_colliding()
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
func check_on_hit() -> bool:
	return status_component.on_hit
func check_is_die() -> bool:
	return status_component.is_die

func turn_left() -> void:
	move_direction = Direction.Left
	center_point.scale.x = -1.0
func turn_right() -> void:
	move_direction = Direction.Right
	center_point.scale.x = 1.0

func turn_back() -> void:
	if move_direction == Direction.Left:
		turn_right()
	else:
		turn_left()

# var facing_direction : Direction = Direction.Right
enum Direction {
	Left = -1,
	Stop = 0,
	Right = 1,
}
var move_direction : Direction = Direction.Right

func _physics_process(delta: float) -> void:
	pass


func _on_hit_box_area_entered(area: HurtBox) -> void:
	status_component.on_hit = true
	status_component.decrease_hp(area.damage)
	# hit_position = area.coll
	# pass
	# current_speed *= -0.3
	# animation_player.play("hit")
	# state_machine.pause = true
	# sprite_2d.material.set_shader_parameter("hit", true)
	# await animation_player.animation_finished
	# sprite_2d.material.set_shader_parameter("hit", false)
	# state_machine.pause = false
	# state_machine.switch_to("hit")
