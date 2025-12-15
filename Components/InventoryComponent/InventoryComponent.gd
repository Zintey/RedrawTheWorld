extends Node
class_name InventoryComponent

@export var rune_count : int = 20
@export var all_runes : Array[RuneData] = []
@export var skill_count : int = 10
@export var all_skills : Array[SkillData] = []
@export var equipped_skill_count : int = 3
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

func _exit_tree() -> void:
	save_data()


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

func add_skill(skill_data : SkillData) -> bool:
	for i in all_skills.size():
		if all_skills[i] == null:
			all_skills[i] = skill_data
			data_changed.emit()
			return true
	printerr("无法添加技能，技能数量已达上限")
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


#func show_inventory_ui() -> void:
	#var ui_canvase
	#if get_tree().get_nodes_in_group("UICanvas") != []:
		#ui_canvase = get_tree().get_nodes_in_group("UICanvas")[0] as CanvasLayer
	#else:
		#printerr("没有找到UICanvas分组的节点，无法添加符文拖拽项")
		#return
	#var inventory_ui_scene = preload("res://UI/Inventory/inventory_ui.tscn")
	#var inventory_ui = inventory_ui_scene.instantiate()
	#ui_canvase.add_child(inventory_ui)
	#
