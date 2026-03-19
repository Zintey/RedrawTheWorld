class_name LeftSkillPanel
extends Control

# 这里存放玩家真实的 8 个技能数据
@export var player_skills: Array[SkillData] = [] 

@onready var workbench: SkillTemplateUI = %SkillTemplateUI
@onready var grid_container: GridContainer = %SkillGridContainer

var mini_slots: Array[MiniSkillSlotUI] = []
var current_selected_index: int = 0

func _ready() -> void:
	# 1. 收集下层所有的微缩槽
	for child in grid_container.get_children():
		if child is MiniSkillSlotUI:
			mini_slots.append(child)
			child.slot_clicked.connect(_on_mini_slot_clicked)
			
	# 2. 初始化数据（防止报错，如果没有 8 个数据，就塞入空的 SkillData）
	while player_skills.size() < 8:
		player_skills.append(SkillData.new())
		
	# 3. 将 8 个数据绑定给 8 个槽位
	for i in range(8):
		if i < mini_slots.size():
			mini_slots[i].set_skill_data(player_skills[i])
			
	# 4. 【关键联动】：监听全局符文掉落！
	# 玩家在上层工作台装卸符文后，下层微缩图标需要立刻刷新（如果动了核心符文的话）
	EventBus.rune_drag_ended.connect(_on_any_rune_changed)
	
	# 5. 默认选中第 1 个技能进行编辑
	call_deferred("select_slot", 0)

# ==================== 核心调度逻辑 ====================

func select_slot(index: int) -> void:
	current_selected_index = index
	
	# 1. 更新下层 8 个图标的虚化状态
	for i in range(mini_slots.size()):
		mini_slots[i].set_selected(i == index)
		
	# 2. 刷新上层大面板，投影出被选中技能的详细符文
	if index < player_skills.size():
		workbench.update_skill_data(player_skills[index])

# 当任意一个下层微缩槽被点击时触发
func _on_mini_slot_clicked(slot: MiniSkillSlotUI) -> void:
	var index = mini_slots.find(slot)
	if index != -1 and index != current_selected_index:
		select_slot(index) # 切换标签页

# 当玩家在上层拖拽完符文松手时触发
func _on_any_rune_changed(rune_data, slot) -> void:
	# 粗暴但有效：刷新所有微缩槽的图标，确保刚装上的核心符文能立刻显示出来
	for mini in mini_slots:
		mini.refresh_icon()