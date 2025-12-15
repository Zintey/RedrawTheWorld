@tool
extends PanelContainer
class_name RuneSlotUI

@export var slot_id : int = -1
signal rune_data_changed(rune_data : RuneData, slot_id : int)
@export var rune_data : RuneData:
	set (value):
		if value == null:
			rune_data = null
			if rune_icon != null:
				rune_icon.texture = null
		rune_data = value
		if rune_icon != null and rune_data != null:
			rune_icon.texture = rune_data.icon
		rune_data_changed.emit(rune_data, slot_id)
		
@export var slot_type : RuneData.RuneType = RuneData.RuneType.ALL
@onready var rune_icon: TextureRect = $MarginContainer/rune_icon
@onready var button: TextureButton = $MarginContainer/Button


func init(_rune_data : RuneData, _slot_id : int, _slot_type : RuneData.RuneType = RuneData.RuneType.ALL) -> void:
	rune_data = _rune_data
	slot_id = _slot_id
	slot_type = _slot_type

func set_rune_data(_rune_data : RuneData) -> void:
	rune_data = _rune_data

func _ready() -> void:
	if rune_data:
		rune_icon.texture = rune_data.icon




func _on_button_button_up() -> void:
	if rune_data == null or rune_data.type == RuneData.RuneType.LOCKON:
		return
	EventBus.rune_drag_ended.emit(rune_data, self)



func _on_button_button_down() -> void:
	if rune_data == null or rune_data.type == RuneData.RuneType.LOCKON:
		return
	EventBus.rune_drag_started.emit(rune_data, self)
	rune_icon.texture = null


func _on_button_mouse_entered() -> void:
	if rune_data == null:
		return
	UIManager.rune_brief_requested.emit(rune_data)
	EventBus.mouse_in_rune_slot.emit(self)



func _on_button_mouse_exited() -> void:
	if rune_data == null:
		return
	UIManager.rune_brief_closed.emit()
	EventBus.mouse_out_rune_slot.emit(self)
