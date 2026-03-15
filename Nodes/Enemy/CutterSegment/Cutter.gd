@tool
extends EnemyBase
class_name Cutter

@export_category("Cutter Settings")
@export var attack_threshold: float = 200.0
@export var idle_speed: float = 50.0
@export var aim_speed: float = 2.0         ## 【新增】：冲刺前的瞄准转身速度（弧度/秒）
@export var rotate_move_speed: float = 80.0
@export var sprint_max_speed: float = 400.0
@export var sprint_curve: Curve

@onready var hit_box: HitBox = %HitBox
@onready var warn_area: Area2D = %WarnArea
@onready var rotatable_pivot: Node2D = %RotatablePivot

func _ready() -> void:
	super._ready()
	has_gravity = false
	
	if warn_area:
		warn_area.body_entered.connect(_on_warn_area_entered)

func _on_warn_area_entered(body: Node2D) -> void:
	if body is Player:
		acquire_target(body) 