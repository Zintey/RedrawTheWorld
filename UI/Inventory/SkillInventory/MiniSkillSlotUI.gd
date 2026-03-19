class_name MiniSkillSlotUI
extends PanelContainer

signal slot_clicked(slot_node: MiniSkillSlotUI)

@export var default_empty_icon: Texture2D = preload("res://Assets/UI/health_item.png")
@export var skill_data: SkillData

@onready var skill_icon: TextureRect = $MarginContainer/Icon

func _ready() -> void:
	# 绑定鼠标与点击事件
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

# 传入数据并刷新显示
func set_skill_data(data: SkillData) -> void:
	skill_data = data
	refresh_icon()

# 核心逻辑：获取第一个核心符文作为图标
func refresh_icon() -> void:
	if skill_data == null:
		skill_icon.texture = default_empty_icon
		return

	var has_core = false
	for rune in skill_data.core_rune_list:
		if rune != null:
			skill_icon.texture = rune.icon
			has_core = true
			break

	if not has_core:
		skill_icon.texture = default_empty_icon

# UI 表现：被选中时半虚化
func set_selected(is_selected: bool) -> void:
	if is_selected:
		self.modulate.a = 0.4 # 处于“正在编辑”状态，半透明
	else:
		self.modulate.a = 1.0 # 正常状态

# 点击检测 (代替 Button)
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		slot_clicked.emit(self)

# 悬浮显示简介
func _on_mouse_entered() -> void:
	if skill_data != null:
		# 确保关掉符文简介，呼出技能简介
		UIManager.rune_brief_closed.emit()
		UIManager.skill_brief_requested.emit(skill_data)

func _on_mouse_exited() -> void:
	if skill_data != null:
		UIManager.skill_brief_closed.emit()