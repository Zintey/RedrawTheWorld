class_name LeftSkillPanel
extends Control

var player_skills: Array[SkillData] = [] 

@onready var workbench: SkillTemplateUI = %SkillTemplateUI
@onready var grid_container: GridContainer = %SkillGridContainer

var mini_slots: Array[MiniSkillSlotUI] = []
var current_selected_index: int = 0

func _ready() -> void:
	for child in grid_container.get_children():
		if child is MiniSkillSlotUI:
			mini_slots.append(child)
			child.slot_clicked.connect(_on_mini_slot_clicked)
			
	EventBus.rune_drag_ended.connect(_on_any_rune_changed)
	
	# 【新增】：接听来自右侧仓库的双击自动装配请求
	EventBus.rune_auto_equip_requested.connect(_on_rune_auto_equip_requested)

func init_skills(skills: Array[SkillData]) -> void:
	player_skills = skills
	
	for i in range(mini_slots.size()):
		if i < player_skills.size():
			mini_slots[i].set_skill_data(player_skills[i])
		else:
			mini_slots[i].set_skill_data(null)
			
	call_deferred("select_slot", 0)

func select_slot(index: int) -> void:
	current_selected_index = index
	
	for i in range(mini_slots.size()):
		mini_slots[i].set_selected(i == index)
		
	if index < player_skills.size() and player_skills[index] != null:
		workbench.update_skill_data(player_skills[index])

func _on_mini_slot_clicked(slot: MiniSkillSlotUI) -> void:
	var index = mini_slots.find(slot)
	if index != -1 and index != current_selected_index:
		select_slot(index)

func _on_any_rune_changed(rune_data, slot) -> void:
	for mini in mini_slots:
		mini.refresh_icon()

# ==================== 方案 B：双击自动挤压装配 ====================
func _on_rune_auto_equip_requested(rune_data: RuneData) -> void:
	print("【测试】左侧面板收到双击请求，准备装配：", rune_data.display_name)
	
	if current_selected_index < 0 or current_selected_index >= player_skills.size(): 
		print("【测试失败】：当前没有选中的技能！")
		return
	var current_skill = player_skills[current_selected_index]
	if current_skill == null: 
		print("【测试失败】：选中的技能为空壳！")
		return

	var target_list : Array[RuneData] = []
	
	# 1. 识别符文类型，锁定对应数组
	match rune_data.type:
		RuneData.RuneType.TRIGGER: target_list = current_skill.trigger_rune_list
		RuneData.RuneType.CORE: target_list = current_skill.core_rune_list
		RuneData.RuneType.MODIFIER: target_list = current_skill.modifier_rune_list
		_: 
			print("【测试失败】：未知符文类型")
			return

	if target_list.size() == 0: 
		print("【测试失败】：该技能没有对应的槽位可以装配！")
		return

	var inserted = false
	# 2. 尝试寻找第一个空位
	for i in range(target_list.size()):
		if target_list[i] == null:
			target_list[i] = rune_data
			inserted = true
			break
	
	# 3. 槽位已满，执行推入与挤出
	if not inserted:
		var kicked_out = target_list[0]
		if kicked_out != null:
			# 将最前面的老符文退回仓库
			EventBus.rune_quick_unequip_requested.emit(kicked_out)
		
		# 队列全体前移
		for i in range(1, target_list.size()):
			target_list[i - 1] = target_list[i]
		
		# 新符文塞入末尾
		target_list[target_list.size() - 1] = rune_data

	# 4. 成功上膛，通知仓库销毁该符文的实体
	EventBus.rune_auto_equipped.emit(rune_data)
	
	# 5. 瞬间刷新界面
	workbench.update_skill_data(current_skill)
	_on_any_rune_changed(null, null)