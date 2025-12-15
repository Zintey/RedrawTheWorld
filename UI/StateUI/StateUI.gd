@tool
extends PanelContainer
class_name StateUI

const Health_Item = preload("uid://dumkogvctaypc")
const Stamina_Item = preload("uid://qqvdrcp8x3qc")

var stastus_component : StatusComponent
@onready var health_box: HBoxContainer = %HealthBox
@onready var stamina_box: HBoxContainer = %StaminaBox

func init(_stastus_component : StatusComponent) -> void:
	stastus_component = _stastus_component


func _ready() -> void:
	EventBus.player_die.connect(func () :
		init_health_box()
		init_stamina_box()
		# update_health_box(stastus_component.hp, stastus_component._current_hp)
		# update_stamina_box(stastus_component.stamina, stastus_component._current_stamina)
		# print("ewaerassfd")
	)
	update_health_box(stastus_component.hp, stastus_component._current_hp)
	update_stamina_box(stastus_component.stamina, stastus_component._current_stamina)
	
	stastus_component.hp_change.connect(update_health_box)
	stastus_component.stamina_change.connect(update_stamina_box)



func init_health_box() -> void:
	for item in health_box.get_children():
		item.queue_free()
func add_health_item() -> void:
	var health_item = Health_Item.instantiate()
	health_box.add_child(health_item)

func init_stamina_box() -> void:	
	for item in stamina_box.get_children():
		item.queue_free()

func add_stamina_item() -> void:
	var stamina_item = Stamina_Item.instantiate()
	stamina_box.add_child(stamina_item)

func update_health_box(max_hp : int, hp : int) -> void:
	for i in range(health_box.get_child_count(), max_hp):
		add_health_item()
	for i in range(max_hp):
		#var health_item = Health_Item.instantiate()
		if i <= hp - 1:
			health_box.get_children()[i].show_item()
		else:
			health_box.get_children()[i].hidden_item()
		#health_box.add_child(health_item)

func update_stamina_box(max_stamina : int,stamina : int) -> void:
	for i in range(stamina_box.get_child_count(), max_stamina):
		add_stamina_item()
	for i in range(max_stamina):
		#var stamina_item = Stamina_Item.instantiate()
		if i <= stamina - 1:
			stamina_box.get_children()[i].show_item()
		else:
			stamina_box.get_children()[i].hidden_item()

		#stamina_box.add_child(stamina_item)
	
