extends Node2D
class_name U1Bullet

@export var speed: float = 600.0 ## 子弹飞行速度

@onready var hit_box: Area2D = $HitBox
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# 飞出屏幕边缘自动销毁，防止内存泄漏
	if screen_notifier:
		screen_notifier.screen_exited.connect(func(): queue_free())

func set_speed(_speed : float):
	speed = _speed

func _process(delta: float) -> void:
	# 绝对直线平飞
	global_position += direction * speed * delta

func launch(dir: Vector2) -> void:
	direction = dir.normalized()
	# 如果朝左飞，翻转子弹
	if direction.x < 0:
		scale.x = -1