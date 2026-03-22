extends PanelContainer
class_name RunesInventoryUI

const RUNESLOTUI = preload("res://UI/Rune/rune_slot_ui.tscn")

@onready var inventory_name_label: Label = %InventoryNameLabel
@onready var runes_grid_container: GridContainer = %RunesGridContainer
@onready var vbox_container: VBoxContainer = $MarginContainer/VBoxContainer

var all_runes: Array[RuneData] = []
# 状态记忆：记住玩家当前选的是哪个分类，默认是全部
var current_filter: RuneData.RuneType = RuneData.RuneType.ALL
var tab_group: ButtonGroup = ButtonGroup.new()

func _ready() -> void:
	_create_tabs()

# 用代码动态生成标签页（免去了手动拖拽 UI 节点的麻烦）
func _create_tabs() -> void:
	var tab_box = HBoxContainer.new()
	tab_box.alignment = BoxContainer.ALIGNMENT_CENTER
	# 将页签栏插入到标题和滚动区之间 (Index = 1)
	vbox_container.add_child(tab_box)
	vbox_container.move_child(tab_box, 1)

	var tabs = [
		{"name": "全部", "type": RuneData.RuneType.ALL},
		{"name": "触发", "type": RuneData.RuneType.TRIGGER},
		{"name": "核心", "type": RuneData.RuneType.CORE},
		{"name": "辅助", "type": RuneData.RuneType.MODIFIER}
	]

	for i in range(tabs.size()):
		var btn = Button.new()
		btn.text = tabs[i].name
		btn.toggle_mode = true # 开启单选模式
		btn.button_group = tab_group # 加入同一个按钮组，实现互斥
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_font_size_override("font_size", 12) # 字体稍微秀气一点
		
		# 默认选中当前状态
		if tabs[i].type == current_filter:
			btn.button_pressed = true
		
		# 绑定点击事件，使用 bind 安全传递参数
		btn.pressed.connect(_on_tab_pressed.bind(tabs[i].type))
		tab_box.add_child(btn)

func _on_tab_pressed(type: RuneData.RuneType) -> void:
	if current_filter != type:
		current_filter = type
		refresh_ui()

# 大管家每次修改数据，都会调用这个入口
func set_runes_inventory(runes: Array[RuneData]) -> void:
	all_runes = runes
	refresh_ui()

# ==================== 核心过滤与重建逻辑 ====================
func refresh_ui() -> void:
	if not is_instance_valid(runes_grid_container): return
	
	# 1. 砸碎旧视图 (流派A)
	for child in runes_grid_container.get_children():
		child.queue_free()

	var valid_count = 0
	var total_capacity = all_runes.size()
	# 保证视觉上至少有20个格子
	if total_capacity < 20: total_capacity = 20 

	# 2. 生成过滤后的真实数据格子
	for i in range(all_runes.size()):
		var rune = all_runes[i]
		if rune != null:
			# 如果是“全部”页签，或者类型匹配，就显示
			if current_filter == RuneData.RuneType.ALL or rune.type == current_filter:
				_create_slot(rune, i)
				valid_count += 1
		else:
			# 只有在“全部”页签下，才把真实的 null 空位生成出来，保证1:1对应
			if current_filter == RuneData.RuneType.ALL:
				_create_slot(null, i)
				valid_count += 1

	# 3. 补齐视觉上的空壳（方案A：压缩显示）
	# 如果不是“全部”页签，由于过滤掉了其他符文和真实的空位，我们需要用假空壳补满20格
	if current_filter != RuneData.RuneType.ALL:
		for i in range(valid_count, total_capacity):
			_create_slot(null, -1) # -1 代表这是一个“假”的视觉占位符

func _create_slot(rune_data: RuneData, real_index: int) -> void:
	var slot = RUNESLOTUI.instantiate() as RuneSlotUI
	# slot_type 固定为 ALL，代表这是仓库里的格子，允许接收所有符文，并保留双击装配功能
	slot.init(rune_data, real_index, RuneData.RuneType.ALL)
	slot.rune_data_changed.connect(_on_rune_data_changed)
	runes_grid_container.add_child(slot)

# ==================== 对策B：智能收容逻辑 ====================
func _on_rune_data_changed(new_rune_data: RuneData, slot_id: int) -> void:
	if slot_id != -1:
		# 真实位置的合法交换
		all_runes[slot_id] = new_rune_data
	else:
		# 玩家把符文强行拖进了一个“假空壳”里！
		if new_rune_data != null:
			# 【核心修复】：延迟一帧发送收容请求！
			# 让 RuneSlotUI 的交换代码先彻底跑完，源格子清空自己后，再让大管家重绘 UI。
			EventBus.call_deferred("emit_signal", "rune_quick_unequip_requested", new_rune_data)