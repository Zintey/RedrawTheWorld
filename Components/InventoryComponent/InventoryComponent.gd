extends Node
class_name InventoryComponent

@export var rune_count : int = 20
@export var all_runes : Array[RuneData] = []
@export var skill_count : int = 10
@export var all_skills : Array[SkillData] = []

# 【核心修改】：将技能栏容量固定为 8
@export var equipped_skill_count : int = 8 
@export var equipped_skills : Array[SkillData] = []

signal data_changed()

func load_data():
	var data : Dictionary = SceneManager.load_data_by_UID("Player")
	if data.has("all_runes"):
		all_runes = data["all_runes"]
	if data.has("all_skills"):
		all_skills = data["all_skills"]
	if data.has("equipped_skills"):
		equipped_skills = data["equipped_skills"]

func save_data():
	var data : Dictionary = {
		"all_runes" : all_runes.duplicate_deep(),
		"all_skills" : all_skills.duplicate_deep(),
		"equipped_skills" : equipped_skills.duplicate_deep()
	}
	SceneManager.save_data_by_UID("Player", data)

func _ready() -> void:
	all_runes.resize(rune_count)
	all_skills.resize(skill_count)
	equipped_skills.resize(equipped_skill_count)
	load_data()
	
	for i in range(equipped_skill_count):
		if equipped_skills[i] == null:
			equipped_skills[i] = SkillData.new()

	# 【新增】：监听快捷装卸事件
	if not EventBus.rune_quick_unequip_requested.is_connected(_on_rune_quick_unequip_requested):
		EventBus.rune_quick_unequip_requested.connect(_on_rune_quick_unequip_requested)
	if not EventBus.rune_auto_equipped.is_connected(_on_rune_auto_equipped):
		EventBus.rune_auto_equipped.connect(_on_rune_auto_equipped)

# 【新增】：将卸下的符文塞回仓库
func _on_rune_quick_unequip_requested(rune_data: RuneData) -> void:
	add_rune(rune_data)

# 【新增】：自动装配成功后，将其从仓库彻底扣除
func _on_rune_auto_equipped(rune_data: RuneData) -> void:
	remove_rune(rune_data)

func add_rune(rune_data : RuneData) -> bool:
	for i in all_runes.size():
		if all_runes[i] == null:
			all_runes[i] = rune_data
			data_changed.emit()
			return true
	printerr("无法添加符文，符文数量已达上限")
	return false

func add_runes(rune_list : Array[RuneData]) -> bool:
	var flag = true
	for rune in rune_list:
		flag = flag and add_rune(rune)
	return flag

func remove_rune(rune_data : RuneData) -> bool:
	if rune_data in all_runes:
		all_runes.erase(rune_data)
		data_changed.emit()
		return true
	return false

func add_skill(new_skill: SkillData) -> bool:
	# 遍历 8 个槽位，寻找空位 (null)
	for i in range(equipped_skills.size()):
		if equipped_skills[i] == null:
			equipped_skills[i] = new_skill
			# 发送数据改变信号，让 UI 刷新（此处根据你原有的信号名来写）
			# EventBus.inventory_data_changed.emit() 或者类似更新底栏的信号
			return true
			
	# 如果循环结束都没找到空位，说明 8 个槽全满！
	return false

func add_skills(skill_list : Array[SkillData]) -> bool:
	var flag = true
	for skill in skill_list:
		flag = flag and add_skill(skill)
	return flag

func remove_skill(skill_data : SkillData) -> bool:
	if skill_data in all_skills:
		all_skills.erase(skill_data)
		data_changed.emit()
		return true
	return false

func equip_skill(skill_data : SkillData) -> bool:
	if equipped_skills.size() >= equipped_skill_count:
		printerr("无法装备技能，已达装备上限")
		return false
	if skill_data in equipped_skills:
		printerr("该技能已装备")
		return false
	equipped_skills.append(skill_data)
	data_changed.emit()
	return true

func unequip_skill(skill_data : SkillData) -> bool:
	if skill_data in equipped_skills:
		equipped_skills.erase(skill_data)
		data_changed.emit()
		return true
	return false