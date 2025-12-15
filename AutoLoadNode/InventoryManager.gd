# 用来管理符文的拖拽和简介显示，不参与保存符文和技能

extends Node

const RUNEITEMUI = preload("res://UI/Rune/rune_item_ui.tscn")
var drag_rune_item : RuneItemUI = null
var mouse_under_rune_slot : RuneSlotUI = null

const SKILLTEMPLATEUI = preload("res://UI/Skill/SkillTemplate/skill_template_ui.tscn")
var drag_skill_item : SkillTemplateUI = null
var mouse_under_skill_slot : SkillSlotUI = null


func _ready() -> void:
	EventBus.rune_drag_started.connect(drag_rune_begin)
	EventBus.rune_drag_ended.connect(drag_rune_end)
	EventBus.skill_drag_started.connect(drag_skill_begin)
	EventBus.skill_drag_ended.connect(drag_skill_end)
	EventBus.mouse_in_rune_slot.connect(set_mouse_under_rune_slot)
	EventBus.mouse_out_rune_slot.connect(clear_mouse_under_rune_slot)
	EventBus.mouse_in_skill_slot.connect(set_mouse_under_skill_slot)
	EventBus.mouse_out_skill_slot.connect(clear_mouse_under_skill_slot)
	
func drag_rune_begin(rune_data: RuneData, start_slot : RuneSlotUI) -> void:
	if drag_rune_item != null:
		drag_rune_item.queue_free()
	drag_rune_item = RUNEITEMUI.instantiate() as RuneItemUI
	drag_rune_item.init(rune_data)
	# var ui_canvase
	# if get_tree().get_nodes_in_group("UICanvas") != []:
	# 	ui_canvase = get_tree().get_nodes_in_group("UICanvas")[0] as CanvasLayer
	# else:
	# 	printerr("没有找到UICanvas分组的节点，无法添加符文拖拽项")
	# 	return
	UIManager.add_child(drag_rune_item)

func drag_rune_end(rune_data: RuneData, start_slot : RuneSlotUI) -> void:
	if drag_rune_item != null:
		var mouse_position = start_slot.get_global_mouse_position()
		for slot in get_tree().get_nodes_in_group("RuneSlot"):
			var rune_slot = slot as RuneSlotUI
			if !(mouse_position.x >= rune_slot.get_global_position().x 
				and mouse_position.x <= rune_slot.get_global_position().x + rune_slot.size.x 
				and mouse_position.y >= rune_slot.get_global_position().y 
				and mouse_position.y <= rune_slot.get_global_position().y + rune_slot.size.y):
				continue # 不在这个槽位范围内
			if rune_slot.rune_data and rune_slot.rune_data.type == RuneData.RuneType.LOCKON:
				break # 不能放置到锁定符文槽位
			if rune_slot.slot_type == RuneData.RuneType.ALL or rune_slot.slot_type == rune_data.type:
				var temp_rune_data = rune_slot.rune_data.duplicate() if rune_slot.rune_data else null
				rune_slot.set_rune_data(rune_data)
				start_slot.set_rune_data(temp_rune_data)
				
				drag_rune_item.queue_free()
				drag_rune_item = null
				return
			else:
				break
	start_slot.set_rune_data(rune_data)
	drag_rune_item.queue_free()
	drag_rune_item = null

# func drag_rune_end(rune_data: RuneData, start_slot : RuneSlotUI) -> void:
# 	if drag_rune_item != null:
# 		if mouse_under_rune_slot != null:
# 			if (mouse_under_rune_slot.rune_data and mouse_under_rune_slot.rune_data.type != RuneData.RuneType.LOCKON):
# 				if mouse_under_rune_slot.slot_type == RuneData.RuneType.ALL or mouse_under_rune_slot.slot_type == rune_data.type:
# 			var temp_rune_data = mouse_under_rune_slot.rune_data
# 			mouse_under_rune_slot.set_rune_data(rune_data)
# 			start_slot.set_rune_data(temp_rune_data)
			
# 			drag_rune_item.queue_free()
# 			drag_rune_item = null
# 			return
# 	start_slot.set_rune_data(rune_data)
# 	drag_rune_item.queue_free()
# 	drag_rune_item = null


func drag_skill_begin(skill_data: SkillData, start_slot : SkillSlotUI) -> void:
	if drag_skill_item != null:
		drag_skill_item.queue_free()
	drag_skill_item = SKILLTEMPLATEUI.instantiate() as SkillTemplateUI
	drag_skill_item.init(skill_data, true)
	# var ui_canvase
	# if get_tree().get_nodes_in_group("UICanvas") != []:
	# 	ui_canvase = get_tree().get_nodes_in_group("UICanvas")[0] as CanvasLayer
	# else:
	# 	printerr("没有找到UICanvas分组的节点，无法添加符文拖拽项")
	# 	return
	UIManager.add_child(drag_skill_item)

func drag_skill_end(skill_data: SkillData, start_slot : SkillSlotUI) -> void:
	if drag_skill_item != null:
		var mouse_position = start_slot.get_global_mouse_position()
		for slot in get_tree().get_nodes_in_group("SkillSlot"):
			var skill_slot = slot as SkillSlotUI
			if !(mouse_position.x >= skill_slot.get_global_position().x 
				and mouse_position.x <= skill_slot.get_global_position().x + skill_slot.size.x 
				and mouse_position.y >= skill_slot.get_global_position().y 
				and mouse_position.y <= skill_slot.get_global_position().y + skill_slot.size.y):
				continue # 不在这个槽位范围内

			var temp_skill_data = skill_slot.skill_data
			skill_slot.set_skill_data(skill_data)
			start_slot.set_skill_data(temp_skill_data)
			
			drag_skill_item.queue_free()
			drag_skill_item = null
			return
	start_slot.set_skill_data(skill_data)
	drag_skill_item.queue_free()
	drag_skill_item = null

func set_mouse_under_rune_slot(rune_slot : RuneSlotUI) -> void:
	mouse_under_rune_slot = rune_slot
func clear_mouse_under_rune_slot() -> void:
	mouse_under_rune_slot = null

func set_mouse_under_skill_slot(skill_slot : SkillSlotUI) -> void:
	mouse_under_skill_slot = skill_slot
func clear_mouse_under_skill_slot() -> void:
	mouse_under_skill_slot = null
