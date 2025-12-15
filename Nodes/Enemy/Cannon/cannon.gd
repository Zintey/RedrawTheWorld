extends CharacterBody2D
class_name Cannon

var UID : String 

# func _ready() -> void:
	# UID = self.owner.name + "/" + self.name
	# var data : Dictionary = SceneManager.load_data_by_UID(UID)
	# if data.has("is_die"):
		# status_component.on_hit = data["is_die"]
		# status_component.is_die = data["is_die"]

# func _exit_tree() -> void:
	# var data : Dictionary = {
		# "is_die" : status_component.is_die
	# }
	# SceneManager.save_data_by_UID(UID, data)

@export var rotate_speed : float = 1.5
var current_rotate_speed : float = 0.0

var target_position : Vector2 = Vector2.ZERO
var target_body : Node2D
var on_follow : bool = false

@onready var turn_right_cast_d: RayCast2D = %TurnRightCastD
@onready var turn_right_cast_u: RayCast2D = %TurnRightCastU
@onready var turn_left_cast_d: RayCast2D = %TurnLeftCastD
@onready var turn_left_cast_u: RayCast2D = %TurnLeftCastU
@onready var warn_area: Area2D = %WarnArea

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var center_point: Node2D = %CenterPoint
@onready var fire_point: Node2D = %FirePoint
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var state_machine: Node = $StateMachine
@onready var hurt_box: HurtBox = %HurtBox
@onready var hit_box: HitBox = %HitBox
@onready var status_component: StatusComponent = %StatusComponent

enum Direction {
	Left = -1,
	Stop = 0,
	Right = 1
}

var rotate_direction : Direction = Direction.Right

func check_can_turn_left() -> bool:
	return !(turn_left_cast_d.is_colliding() or turn_left_cast_u.is_colliding())
func check_can_turn_right() -> bool:
	return !(turn_right_cast_d.is_colliding() or turn_right_cast_u.is_colliding())
func check_is_warning() -> bool:
	return target_body != null
func check_lose_warning() -> bool:
	return target_body == null
func check_on_hit() -> bool:
	return status_component.on_hit
func check_is_die() -> bool:
	return status_component.is_die

func turn_left() -> void:
	rotate_direction = Direction.Left
	current_rotate_speed = 0.0
func turn_right() -> void:
	rotate_direction = Direction.Right
	current_rotate_speed = 0.0
func turn_stop() -> void:
	rotate_direction = Direction.Stop
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


func _on_warn_area_body_entered(body: Node2D) -> void:
	target_body = body


func _on_lose_warn_body_exited(body: Node2D) -> void:
	target_body = null


func _on_hit_box_area_entered(area: HurtBox) -> void:
	target_body = get_tree().get_first_node_in_group("Player")
	status_component.on_hit = true
	status_component.decrease_hp(area.damage)
