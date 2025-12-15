extends Panel
class_name HealthItem
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_show = true

func show_item():
	if !is_show:
		animation_player.play("show")
	is_show = true

func hidden_item():
	if is_show:
		animation_player.play("hidden")
	is_show = false
