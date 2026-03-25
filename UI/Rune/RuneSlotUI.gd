@tool
extends PanelContainer
class_name RuneSlotUI

@export var drag_sfx : AudioEvent
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

# 获取高光边框 (如果你场景里没加这个，可以注释掉高光相关的代码)
@onready var highlight_border: Panel = $MarginContainer/HighlightBorder

# 【新增】：手搓双击的时间变量
var last_click_time: float = 0.0
const DOUBLE_CLICK_TIME: float = 0.3 # 0.3秒内连点算双击

func init(_rune_data : RuneData, _slot_id : int, _slot_type : RuneData.RuneType = RuneData.RuneType.ALL) -> void:
	rune_data = _rune_data
	slot_id = _slot_id
	slot_type = _slot_type

func set_rune_data(_rune_data : RuneData) -> void:
	rune_data = _rune_data

func _ready() -> void:
	if rune_data:
		rune_icon.texture = rune_data.icon
		
	# 强制绑定根节点的悬停信号，不再依赖 Button
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	
	EventBus.rune_drag_started.connect(_on_global_drag_started)
	EventBus.rune_drag_ended.connect(_on_global_drag_ended)

# ==================== 快捷交互：双击装配 & 右键卸下 ====================
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		
		# 【1. 右键一键卸下】 -> 仅限左侧工作台里的符文（slot_type 不是 ALL）
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if slot_type != RuneData.RuneType.ALL and rune_data != null and rune_data.type != RuneData.RuneType.LOCKON:
				var temp = rune_data
				self.rune_data = null # 清空自己，引发底层数据刷新
				UIManager.rune_brief_closed.emit()
				EventBus.rune_quick_unequip_requested.emit(temp) # 叫大管家收回仓库
			
			elif slot_type == RuneData.RuneType.ALL and rune_data != null:
					print("【测试成功】仓库符文被右击：", rune_data.display_name)
					EventBus.rune_auto_equip_requested.emit(rune_data)
				
		# 【2. 左键手搓双击装配】 -> 仅限右侧仓库里的符文（slot_type 是 ALL）
		elif event.button_index == MOUSE_BUTTON_LEFT:
			var current_time = Time.get_ticks_msec() / 1000.0
			if current_time - last_click_time < DOUBLE_CLICK_TIME:
				# 确认是双击！
				last_click_time = 0.0 
				if slot_type == RuneData.RuneType.ALL and rune_data != null:
					print("【测试成功】仓库符文被双击：", rune_data.display_name)
					EventBus.rune_auto_equip_requested.emit(rune_data)
			else:
				# 记录第一次点击的时间
				last_click_time = current_time
		

# ==================== 全局高亮逻辑 ====================
func _on_global_drag_started(dragged_rune: RuneData, start_slot: RuneSlotUI) -> void:
	if dragged_rune == null: return
	if slot_type == RuneData.RuneType.ALL or slot_type == dragged_rune.type:
		if highlight_border: highlight_border.show()
		if highlight_border: highlight_border.modulate = Color(1, 1, 1, 1) 
		self.modulate = Color(1, 1, 1, 1)
	else:
		if highlight_border: highlight_border.hide()
		self.modulate = Color(0.4, 0.4, 0.4, 1.0) 

func _on_global_drag_ended(dragged_rune: RuneData, start_slot: RuneSlotUI) -> void:
	if highlight_border: highlight_border.hide()
	AudioManager.play_sfx(drag_sfx)
	self.modulate = Color(1, 1, 1, 1) 

# ==================== 原生拖拽三剑客 ====================
func _get_drag_data(at_position: Vector2) -> Variant:
	if rune_data == null or rune_data.type == RuneData.RuneType.LOCKON: return null

	var preview = TextureRect.new()
	preview.texture = rune_data.icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(40, 40) 
	preview.modulate.a = 0.9 
	var control = Control.new()
	control.add_child(preview)
	preview.position = -preview.custom_minimum_size / 2
	set_drag_preview(control)
	
	rune_icon.modulate.a = 0.0
	UIManager.rune_brief_closed.emit()
	EventBus.rune_drag_started.emit(rune_data, self)
	AudioManager.play_sfx(drag_sfx)
	
	return {"source": self, "data": rune_data}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("data") and data["data"] is RuneData:
		var drag_rune = data["data"] as RuneData
		if slot_type == RuneData.RuneType.ALL or slot_type == drag_rune.type:
			if highlight_border: highlight_border.modulate = Color(2.0, 2.0, 2.0, 1.0) 
			return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var source_slot = data["source"]
	var drag_rune = data["data"]

	var temp_data = self.rune_data
	self.rune_data = drag_rune
	source_slot.rune_data = temp_data

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if is_instance_valid(rune_icon):
			rune_icon.modulate.a = 1.0
		if rune_data != null:
			EventBus.rune_drag_ended.emit(rune_data, self)

# ==================== 悬停显示简介 ====================
func _on_mouse_entered() -> void:
	if rune_data == null: return
	# 强行关掉技能简介，确保符文简介独占显示
	UIManager.skill_brief_closed.emit() 
	UIManager.rune_brief_requested.emit(rune_data)
	EventBus.mouse_in_rune_slot.emit(self)

func _on_mouse_exited() -> void:
	if rune_data == null: return
	UIManager.rune_brief_closed.emit()
	EventBus.mouse_out_rune_slot.emit(self)