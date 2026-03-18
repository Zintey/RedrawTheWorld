class_name SkillComponent extends Node

@export var skill_owner : PhysicsBody2D
# 替换为新的组件
@export var stats_component : PlayerStatsComponent
@export var inventory_component : InventoryComponent

var skill_list : Array[SkillData]

var trigger_rune_handler : TriggerRuneHandler

func _ready() -> void:
	# 安全获取名字，防止 skill_owner 为空导致游戏崩溃
	var owner_name: String = skill_owner.name if skill_owner else "未知节点"
	
	if stats_component == null:
		printerr(owner_name, " 的 SkillComponent 没有设置 stats_component 属性！(节点路径: ", get_path(), ")")
	if inventory_component == null:
		printerr(owner_name, " 的 SkillComponent 没有设置 inventory_component 属性！(节点路径: ", get_path(), ")")
	else:
		skill_list = inventory_component.equipped_skills

	trigger_rune_handler = TriggerRuneHandler.new()

func check_skills_triggered() -> SkillData:
	# 遍历技能列表，检查每个技能的触发符文是否被触发
	if !skill_owner.stats_component.has_emitter:
		return null
		
	var triggered_skill : SkillData = null
	for skill in skill_list:
		if skill == null:
			continue
		var is_triggered : bool = check_skill_triggered(skill)
		
		if is_triggered:
			triggered_skill = skill
			# 【修复：把你被我误删的法术工厂逻辑加回来了！】
			var skill_circle = SkillCircleHandler.new(skill, skill_owner)
			add_child(skill_circle)
			# print_debug(skill_owner.name, "技能 ", skill.skill_id, " 被触发")
			
	return triggered_skill

func check_skill_triggered(skill : SkillData) -> bool:
	var trigger_rune_list : Array[RuneData] = skill.trigger_rune_list
	var is_skill_trigger : bool = true if skill.type == skill.SkillType.AND_TRIGGER else false
	var skill_stamina_cost : float = 0.0
	var skill_stamina_cost_multiple : float = 1.0
	
	for rune in skill.modifier_rune_list:
		if rune == null:
			continue
		skill_stamina_cost += rune.stamina_cost
		skill_stamina_cost_multiple *= rune.stamina_cost_multiple
	
	for rune in skill.core_rune_list:
		if rune == null:
			continue
		skill_stamina_cost += rune.stamina_cost
		skill_stamina_cost_multiple *= rune.stamina_cost_multiple

	for trigger_rune in trigger_rune_list:
		if trigger_rune == null:
			continue
		var is_rune_trigger : bool = trigger_rune_handler.check_is_rune_triggered(trigger_rune, skill_owner)
		if skill.type == skill.SkillType.AND_TRIGGER:
			is_skill_trigger = is_skill_trigger and is_rune_trigger
		elif skill.type == skill.SkillType.OR_TRIGGER:
			is_skill_trigger = is_skill_trigger or is_rune_trigger
		
		skill_stamina_cost += trigger_rune.stamina_cost
		skill_stamina_cost_multiple *= trigger_rune.stamina_cost_multiple
	
	# 修改：使用新的 stats_component 和 current_stamina 属性
	if stats_component:
		if is_skill_trigger and stats_component.current_stamina >= skill_stamina_cost * skill_stamina_cost_multiple:
			# print_debug(skill_owner.name, "释放了 ","技能：", skill.skill_id)
			stats_component.reduce_stamina(skill_stamina_cost)
			# print_debug("精力减少：", skill_stamina_cost)
			return true
			
	return false
