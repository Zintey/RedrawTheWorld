@tool
extends EnemyBase
class_name L3Boom

@export_category("L3Boom Settings")
@export var idle_speed : float = 50.0
@export var warning_speed : float = 120.0
@export var wander_radius : float = 200.0
@export var boom_distance : float = 50.0
@onready var warn_area: Area2D = %WarnArea

func _ready() -> void:
	super._ready()
	# 飞行怪，关闭重力
	has_gravity = false
	
	if warn_area:
		warn_area.body_entered.connect(_on_warn_area_body_entered)
		warn_area.body_exited.connect(_on_warn_area_body_exited)

func _on_warn_area_body_entered(body: Node2D) -> void:
	if body is Player:
		acquire_target(body) # 立刻变红并追击

func _on_warn_area_body_exited(body: Node2D) -> void:
	pass # <--- 不调用 lose_target，所以它永远不会遗忘玩家，直到自爆！


func _on_died() -> void:
	remove_from_group("Enemy")
	died.emit(self)
	if state_machine:
		state_machine.switch_to("boom_die")