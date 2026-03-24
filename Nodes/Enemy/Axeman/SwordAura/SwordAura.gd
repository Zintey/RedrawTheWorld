extends Node2D
class_name SwordAura

@export var fly_speed: float = 400.0 # 剑气飞行速度，可以根据难度调整

@onready var hit_box: Area2D = $HitBox
@onready var sprite: Sprite2D = $Sprite2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# 连接屏幕外的检测信号，飞出屏幕边缘自动销毁，绝不漏内存
	if screen_notifier:
		screen_notifier.screen_exited.connect(func(): queue_free())

func _process(delta: float) -> void:
	# 方案A：无视地形和重力，绝对直线平飞！
	global_position += direction * fly_speed * delta

# 接收 Axeman 传过来的发射方向
func launch(dir: Vector2) -> void:
	direction = dir.normalized()
	
	# 如果是往左飞，翻转整个剑气的贴图和判定框
	if direction.x < 0:
		scale.x = -scale.x