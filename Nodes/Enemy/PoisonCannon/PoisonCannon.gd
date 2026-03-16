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
	# 先添加到场景树，确保能获取和设置 global_ 属性
	get_tree().current_scene.add_child(orb)
	
	orb.global_position = fire_point.global_position
	
	# --- 强行获取炮管原点指向 FirePoint 的真实方向 ---
	var dir = fire_point.global_position - global_position
	if dir.length() > 1.0:
		# 如果你把 FirePoint 拖出了一段距离，就用两点之间的真实连线方向
		orb.global_rotation = dir.angle()
	else:
		# 【防暴毙兜底】：如果你的 FirePoint 刚好在原点(0,0)没动过
		# 直接用炮管自身的全局旋转角度，绝对安全！
		orb.global_rotation = global_rotation
	
	# 完美还原你的原始参数调用！
	orb.launch(target_body.global_position + Vector2(0, 15), flight_time)