# EnemyAgent.gd
# 所有敌人的公共基类，替代现在每个敌人各自 extends CharacterBody2D 的写法。
# Cannon / Drone / TrackedCutter / Eden 都改成 extends EnemyAgent。
# 把各自 .gd 里重复的 check_on_hit / check_is_die 和节点引用统一放在这里。

extends CharacterBody2D
class_name EnemyAgent

signal die_signal

# 每个敌人场景里这几个节点的 unique_name 必须保持一致（%AnimationPlayer 等）
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var status_component: StatusComponent  = %StatusComponent
@onready var hit_box: Area2D                    = %HitBox
@onready var hurt_box: Area2D                   = %HurtBox
@onready var state_machine: StateMachine        = $StateMachine

# ---------- 子类通用的检查方法，不需要重复写 ----------
func check_on_hit() -> bool:
	return status_component.on_hit

func check_is_die() -> bool:
	return status_component.is_die

# ---------- 子类通用的受击处理，在 _on_hit_box_area_entered 里调用 ----------
# 子类可以 override 这个方法来添加自己的额外逻辑
func on_hit_box_entered(area: HurtBox) -> void:
	status_component.on_hit = true
	status_component.decrease_hp(area.damage)
