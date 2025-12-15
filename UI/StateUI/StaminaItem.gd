extends Panel
class_name StaminaItem

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func show_item():
	animation_player.play("show")

func hidden_item():
	animation_player.play("hidden")
