extends Node2D
class_name InteractiveItem
@onready var tip_area: Area2D = %TipArea
@onready var interactable_area: Area2D = %InteractableArea
@onready var item_sprite: Sprite2D = %ItemSprite
@onready var tip_text_area = %TipTextArea

var can_interact : bool = false
var is_interacted : bool = false

@export_multiline var tip_text : String = "S 拾取"
@onready var tip_label:Label = $TipTextArea/TipLabel

@export var one_shot = true

func _ready():
	EventBus.interact_request.connect(_try_interact)
	tip_label.text = tip_text
	var data : Dictionary = SceneManager.load_data_by_UID(self.name)
	if data.has("is_interacted"):
		is_interacted = data["is_interacted"] as bool
	
	if is_interacted:
		if one_shot:
			queue_free()
		else:
			tip_label.text = ""

func _exit_tree() -> void:
	var data : Dictionary = {
		"is_interacted" : is_interacted
	}
	SceneManager.save_data_by_UID(self.name, data)


func _process(delta: float) -> void:
	pass

func _try_interact(body : Node2D):
	#print("interact success")
	if can_interact and not is_interacted:
		is_interacted = true
		item_sprite.material.set_shader_parameter("outline_size", 0.0)
		tip_label.text = ""
		take_interact(body)

func take_interact(body : Node2D):
	pass



func _on_tip_area_area_entered(area: Area2D) -> void:
	if is_interacted:
		return
	item_sprite.material.set_shader_parameter("outline_size", 2.0)


func _on_tip_area_area_exited(area: Area2D) -> void:
	if is_interacted:
		return
	item_sprite.material.set_shader_parameter("outline_size", 0.0)


func _on_interactable_area_area_entered(area: Area2D) -> void:
	if is_interacted:
		return
	can_interact = true

func _on_interactable_area_area_exited(area: Area2D) -> void:
	if is_interacted:
		return
	can_interact = false
