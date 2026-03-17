extends Node2D

const POISON_ORB_SCENE = preload("uid://pssblhuk8dch")
@export var flight_time : float = 0.8

@onready var fire_point: Node2D = %FirePoint
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var target_body : Node2D

func fire():
	animation_player.play("fire")

func set_target(target : Node2D):
	target_body = target

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
	orb.launch(target_body.global_position + Vector2(0, 15), dir, flight_time)