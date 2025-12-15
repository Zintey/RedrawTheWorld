extends InteractiveItem



# func _ready():
# 	super()
# 	var data : Dictionary = SceneManager.load_data_by_UID(UID)
# 	if data.has("is_interacted"):
# 		is_interacted = data["is_interacted"] as bool
	
# 	if is_interacted:
# 		queue_free()

# func _exit_tree() -> void:
# 	var data : Dictionary = {
# 		"is_interacted" : is_interacted
# 	}
# 	SceneManager.save_data_by_UID(UID, data)


func take_interact(body : Node2D):

	body = body as Player
	if body:
		body.equip_emitter()
	# print("yes3")
	queue_free()
