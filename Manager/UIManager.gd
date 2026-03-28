extends CanvasLayer

const UI_Map : Dictionary = {
	"InventoryUI" : preload("res://UI/Inventory/inventory_ui.tscn"),
	"RuneBriefUI" : preload("res://UI/Rune/rune_brief_ui.tscn"),
	"SkillBriefUI" : preload("res://UI/Skill/skill_brief_ui.tscn"),
	"StateUI" : preload("uid://bnn0ilaf1c77q"),
	"RestartUI" : preload("uid://dqkcy725qe8jq"),
	"StaminaExhaustTip" : preload("uid://c117x7o152qfa"),
	"LevelTransitionUI": preload("uid://bhxo80b3fo2kb"),
	"CombatActionBarUI": preload("uid://cml8s0s5nwonw"),
	"SkillTemplateBriefUI": preload("uid://cimmppl02uvn8"),
}

# signal rune_world_brief_requested(rune_data: RuneData, target: Node2D)


# --- 新增：用于缓存玩家的四大组件 ---
var player_health: HealthComponent
var player_stats: PlayerStatsComponent
var player_inventory: InventoryComponent
var player_skill: SkillComponent

func _ready() -> void:
	layer = 100

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

	EventBus.player_components_ready.connect(_on_player_components_ready)
	EventBus.level_transition_started.connect(_on_level_transition_started)

	EventBus.rune_world_brief_requested.connect(_show_rune_world_brief)

	EventBus.skill_world_brief_requested.connect(_on_skill_world_brief_requested)
	EventBus.skill_world_brief_closed.connect(_on_skill_world_brief_closed)

var combat_action_bar : CombatActionBarUI

func _on_player_components_ready(h: Node, s: Node, i: Node, sk: Node) -> void:
	player_health = h as HealthComponent
	player_stats = s as PlayerStatsComponent
	player_inventory = i as InventoryComponent
	player_skill = sk as SkillComponent
	
	_on_state_ui_request()
	
	# 【新增】：立刻创建战斗底栏
	if not is_instance_valid(combat_action_bar):
		combat_action_bar = UI_Map["CombatActionBarUI"].instantiate()
		combat_action_bar.init(player_skill, player_stats)
		add_child(combat_action_bar)

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
	
	# 【新增联动】：如果关掉的是背包，恢复显示战斗底栏
	# if top_ui is InventoryUI and is_instance_valid(combat_action_bar):
		# combat_action_bar.show()
		
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
signal inventory_ui_requested()
signal inventory_ui_close()
var inventory_ui : InventoryUI = null
func _on_inventory_ui_requested() -> void:
	if inventory_ui:
		if ui_stack[ui_stack_top_index] == inventory_ui:
			pop_ui()
		return
	
	# 【新增联动】：打开背包时，隐藏战斗底栏
	# if is_instance_valid(combat_action_bar):
		# combat_action_bar.hide()
	
	inventory_ui = UI_Map["InventoryUI"].instantiate()
	inventory_ui.init(player_inventory)
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
func _on_state_ui_request() -> void:
	if not is_instance_valid(state_ui):
		state_ui = UI_Map["StateUI"].instantiate()
		state_ui.init(player_health, player_stats)
		add_child(state_ui)
	# 把新的双组件塞给它
	



signal restart_ui_request()
func _on_restart_ui_request():
	var ui = UI_Map["RestartUI"].instantiate()
	self.add_child(ui)


signal stamina_exhaust_tip_request()
func _on_stamina_exhaust_tip_request():
	var ui = UI_Map["StaminaExhaustTip"].instantiate()
	self.add_child(ui)


# 实例化转场UI并覆盖全屏
func _on_level_transition_started(is_initial_start: bool):
	var transition_ui = UI_Map["LevelTransitionUI"].instantiate()
	transition_ui.z_index = 4096 
	add_child(transition_ui)
	transition_ui.init_transition(is_initial_start)


func _show_rune_world_brief(rune_data: RuneData, target: Node2D) -> void:
	if rune_brief:
		rune_brief.queue_free()
	rune_brief = UI_Map["RuneBriefUI"].instantiate() as RuneBriefUI
	rune_brief.init(rune_data, target)
	self.add_child(rune_brief)


var skill_world_brief: SkillTemplateBriefUI

func _on_skill_world_brief_requested(skill_data: SkillData, target: Node2D) -> void:
	if skill_world_brief:
		skill_world_brief.queue_free() 
		
	skill_world_brief = UI_Map["SkillTemplateBriefUI"].instantiate() 
	skill_world_brief.init(skill_data, target)
	self.add_child(skill_world_brief)

func _on_skill_world_brief_closed() -> void:
	if skill_world_brief:
		skill_world_brief.queue_free()
		skill_world_brief = null
