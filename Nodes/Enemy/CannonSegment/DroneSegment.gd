@tool
extends EnemyBase
class_name DroneSegment

@export_category("Drone Settings")
@export var fly_speed: float = 120.0
@export var min_dist: float = 150.0  
@export var max_dist: float = 300.0  
@export var turn_speed: float = 4.0  ## 【新增】平滑转向的速度

@onready var warn_area: Area2D = %WarnArea
@onready var poison_cannon: Node2D = %PoisonCannon
# @onready var center_point: Node2D = %CenterPoint 

func _ready() -> void:
	super._ready()
	has_gravity = false
	
	if warn_area:
		warn_area.body_entered.connect(_on_warn_area_entered)

func _on_warn_area_entered(body: Node2D) -> void:
	if body is Player:
		acquire_target(body) 
		if poison_cannon and poison_cannon.has_method("set_target"):
			poison_cannon.set_target(body)