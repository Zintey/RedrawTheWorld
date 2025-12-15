extends PanelContainer
class_name RunesInventoryUI

const RUNESLOTUI = preload("res://UI/Rune/rune_slot_ui.tscn")

var runes_inventory : Array[RuneData] = []
@onready var runes_grid_container: GridContainer = %RunesGridContainer
@export var inventory_name : String
@onready var inventory_name_label: Label = %InventoryNameLabel

func set_runes_inventory(_runes_inventory) -> void:
	runes_inventory = _runes_inventory
	for child in runes_grid_container.get_children():
		child.queue_free()
	
	var cnt : int = 0
	for rune_data in runes_inventory:
		var rune_slot : RuneSlotUI = RUNESLOTUI.instantiate()
		rune_slot.init(rune_data, cnt)
		rune_slot.rune_data_changed.connect(func(new_rune_data : RuneData, slot_id : int) -> void:
			runes_inventory[slot_id] = new_rune_data
			# print("Rune data in slot %d changed." % slot_id)
		)
		cnt += 1
		runes_grid_container.add_child(rune_slot)

func _ready() -> void:
	inventory_name_label.text = inventory_name



func _process(delta: float) -> void:
	pass
