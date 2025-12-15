extends CanvasLayer

const UI_Map : Dictionary = {
	"InventoryUI" : preload("res://UI/Inventory/inventory_ui.tscn"),
	"RuneBriefUI" : preload("res://UI/Rune/rune_brief_ui.tscn"),
	"SkillBriefUI" : preload("res://UI/Skill/skill_brief_ui.tscn"),
	"StateUI" : preload("uid://bnn0ilaf1c77q"),
	"RestartUI" : preload("uid://dqkcy725qe8jq"),
	"StaminaExhaustTip" : preload("uid://c117x7o152qfa")
}



func _ready() -> void:
	rune_brief_requested.connect(_show_rune_brief)
	rune_brief_closed.connect(_close_rune_brief)

	skill_brief_requested.connect(_show_skill_brief)
	skill_brief_closed.connect(_close_skill_brief)

	inventory_ui_requested.connect(_on_inventory_ui_requested)
	inventory_ui_close.connect(_on_inventory_ui_close)

	scene_switch_transition_requested.connect(_scene_switch_transition)

	state_ui_request.connect(_on_state_ui_request)

	restart_ui_request.connect(_on_restart_ui_request)

	stamina_exhaust_tip_request.connect(_on_stamina_exhaust_tip_request)


var ui_stack : Array[Node] = []
var ui_stack_top_index : int = -1
func push_ui(ui_node : Control) -> void:
	if ui_stack_top_index < ui_stack.size() - 1:
		for i in range(ui_stack.size() - 1, ui_stack_top_index, -1):
			ui_stack.remove_at(i)
	ui_stack.append(ui_node)
	ui_stack_top_index += 1
	self.add_child(ui_node)
func pop_ui() -> Node:
	if ui_stack_top_index < 0:
		return null
	var top_ui = ui_stack[ui_stack_top_index]
	if top_ui.has_method("close_ui"):
		top_ui.call("close_ui")
	else:
		top_ui.queue_free()
	ui_stack.remove_at(ui_stack_top_index)
	ui_stack_top_index -= 1
	return top_ui

# ESC 关闭栈顶 UI
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CloseUI"):
		pop_ui()


# UI 管理符文简介显示的信号
signal rune_brief_requested(rune_data : RuneData)
signal rune_brief_closed()
var rune_brief : RuneBriefUI = null
func _show_rune_brief(rune_data: RuneData) -> void:
	if rune_brief:
		rune_brief.queue_free()
	rune_brief = UI_Map["RuneBriefUI"].instantiate() as RuneBriefUI
	rune_brief.init(rune_data)
	self.add_child(rune_brief)
func _close_rune_brief() -> void:
	if rune_brief:
		rune_brief.queue_free()

# UI 管理技能简介显示的信号
signal skill_brief_requested(skill_data : SkillData)
signal skill_brief_closed()
var skill_brief : SkillBriefUI = null
func _show_skill_brief(skill_data: SkillData) -> void:
	if skill_brief:
		skill_brief.queue_free()
	skill_brief = UI_Map["SkillBriefUI"].instantiate() as SkillBriefUI
	skill_brief.init(skill_data)
	self.add_child(skill_brief)
func _close_skill_brief() -> void:
	if skill_brief:
		skill_brief.queue_free()


# UI 管理打开背包界面的信号
signal inventory_ui_requested(inventory_component : Node)
signal inventory_ui_close()
var inventory_ui : InventoryUI = null
func _on_inventory_ui_requested(inventory_component : Node) -> void:
	if inventory_ui:
		if ui_stack[ui_stack_top_index] == inventory_ui:
			pop_ui()
		return

	inventory_ui = UI_Map["InventoryUI"].instantiate() as InventoryUI
	inventory_ui.init(inventory_component)
	push_ui(inventory_ui)
func _on_inventory_ui_close():
	if inventory_ui:
		if ui_stack[ui_stack_top_index] == inventory_ui:
			pop_ui()
		return

signal scene_switch_transition_requested(to_black : bool)
signal transition_finished
var _transition_rect: ColorRect = null
var transition_tween : Tween

func _scene_switch_transition(to_black: bool):
	if transition_tween:
		transition_tween.kill()
	transition_tween = get_tree().create_tween()
	transition_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		
	
	if not is_instance_valid(_transition_rect):
		_transition_rect = ColorRect.new()
		_transition_rect.color = Color.BLACK
		_transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		_transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		_transition_rect.z_index = 4096
		add_child(_transition_rect)
		
		_transition_rect.modulate.a = 0.0 if to_black else 1.0

	if to_black:
		transition_tween.tween_property(_transition_rect, "modulate:a", 1.0, 0.2)
	else:
		_transition_rect.modulate.a = 1.0
		transition_tween.tween_property(_transition_rect, "modulate:a", 0.0, 0.2)
		
		transition_tween.tween_callback(_transition_rect.queue_free)

	transition_tween.tween_callback(func(): 
		transition_finished.emit()
	)
	
# 管理玩家状态的ui
signal state_ui_request(status_component : StatusComponent)
var state_ui : StateUI
func _on_state_ui_request(status_component : StatusComponent) -> void:
	if state_ui:
		return
	state_ui = UI_Map["StateUI"].instantiate() as StateUI
	state_ui.init(status_component)
	self.add_child(state_ui)


signal restart_ui_request()
func _on_restart_ui_request():
	var ui = UI_Map["RestartUI"].instantiate()
	self.add_child(ui)


signal stamina_exhaust_tip_request()
func _on_stamina_exhaust_tip_request():
	var ui = UI_Map["StaminaExhaustTip"].instantiate()
	self.add_child(ui)