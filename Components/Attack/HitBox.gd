extends Area2D
class_name HitBox

## 造成的伤害值
@export var damage: int = 1
## 预留：击退力度（以后做受击击退时很有用）
@export var knockback_force: float = 0.0

func _ready() -> void:
	# HitBox 通常不需要自己检测，由 HurtBox 来撞它
	pass