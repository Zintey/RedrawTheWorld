extends Control # 或者你根节点用的 TextureRect/Panel
class_name HealthItemUI

@onready var anim_player: AnimationPlayer = $AnimationPlayer

# 之前旧逻辑里调用的隐藏/显示方法（为了兼容你以前的调用，可以保留）
func show_item() -> void:
	self.show()

func hidden_item() -> void:
	self.hide()

# ==================== 核心状态切换 ====================
func show_full() -> void:
	# 假设你在 AnimationPlayer 里做了一个叫 "full" 的动画（比如显示满红心）
	if anim_player and anim_player.has_animation("full"):
		anim_player.play("full")

func show_half() -> void:
	# 假设 "half" 动画显示半颗心
	if anim_player and anim_player.has_animation("half"):
		anim_player.play("half")

func show_empty() -> void:
	# 假设 "empty" 动画显示空心边框
	if anim_player and anim_player.has_animation("empty"):
		anim_player.play("empty")