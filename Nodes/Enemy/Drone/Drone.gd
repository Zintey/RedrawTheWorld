extends CharacterBody2D
class_name Drone

signal die_signal
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


@export var patrol_range : float = 250.0

var current_move_speed : float
var current_move_direction : Vector2

var enable_gravity : bool = false
var in_obstacle : bool = false

var target_body : Node2D

@onready var center_point: Node2D = $CenterPoint
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var cannon: Cannon = %Cannon
@onready var status_component: Node = %StatusComponent
@onready var hit_box: Area2D = %HitBox
@onready var hurt_box: Area2D = %HurtBox
@onready var state_machine: Node = %StateMachine
# @onready var aoid_obstacle_area: Area2D = $CenterPoint/AoidObstacleArea





func check_can_move() -> bool:
	return !in_obstacle

func check_is_warn() -> bool:
	return target_body != null
func check_lose_target() -> bool:
	return target_body == null

func check_on_hit() -> bool:
	return status_component.on_hit
func check_is_die() -> bool:
	return status_component.is_die





func _on_warn_area_body_entered(body: Node2D) -> void:
	target_body = body

func _on_lose_area_body_exited(body: Node2D) -> void:
	target_body = null

func _on_hit_box_area_entered(area: HurtBox) -> void:
	target_body = get_tree().get_first_node_in_group("Player")
	status_component.on_hit = true
	status_component.decrease_hp(area.damage)
