extends InteractiveItem
class_name Switch

signal switch_to_open

func _ready():
	super()
	if is_interacted:
		item_sprite.frame = 0
		switch_to_open.emit()

func take_interact(body : Node2D):
	
	body = body as Player
	if body:
		switch_to_open.emit()
		item_sprite.frame = 0
