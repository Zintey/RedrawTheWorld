extends Control 
class_name StaminaItemUI

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func show_item() -> void:
	self.show()

func hidden_item() -> void:
	self.hide()

# ==================== 核心状态切换 ====================
func show_full() -> void:
	if anim_player and anim_player.has_animation("full"):
		anim_player.play("full")

func show_half() -> void:
	if anim_player and anim_player.has_animation("half"):
		anim_player.play("half")

func show_empty() -> void:
	if anim_player and anim_player.has_animation("empty"):
		anim_player.play("empty")