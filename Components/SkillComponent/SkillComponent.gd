class_name SkillComponent extends Node

@export var skill_owner : PhysicsBody2D
@export var status_component : StatusComponent
@export var inventory_component : InventoryComponent

var skill_list : Array[SkillData]

var trigger_rune_handler : TriggerRuneHandler

func _ready() -> void:
	# if skill_owner == null:
		# printerr(owner.name, " 的 SkillComponent 没有设置 skill_owner 属性！")
	# await skill_owner.ready
	if status_component == null:
		printerr(skill_owner.name, " 的 SkillComponent 没有设置 status_component 属性！")
	if inventory_component == null:
		printerr(skill_owner.name, " 的 SkillComponent 没有设置 inventory_component 属性！")
	else:
		skill_list = inventory_component.equipped_skills

	trigger_rune_handler = TriggerRuneHandler.new()

func check_skills_triggered() -> SkillData:
	# 遍历技能列表，检查每个技能的触发符文是否被触发
	if !skill_owner.status_component.has_emitter:
		return
	var triggered_skill : SkillData = null
	for skill in skill_list:
		if skill == null:
			continue
		var is_triggered : bool = check_skill_triggered(skill)
		
		if is_triggered:
			triggered_skill = skill
			# print_debug(skill_owner.name, "技能 ", skill.skill_id, " 被触发")
			pass
	return triggered_skill

func check_skill_triggered(skill : SkillData) -> bool:
	var trigger_rune_list : Array[RuneData] = skill.trigger_rune_list
	var is_skill_trigger : bool = true if skill.type == skill.SkillType.AND_TRIGGER else false
	var skill_stamina_cost : float = 0.0
	
	for rune in skill.modifier_rune_list:
		if rune == null:
			continue
		skill_stamina_cost += rune.stamina_cost
	
	for rune in skill.core_rune_list:
		if rune == null:
			continue
		skill_stamina_cost += rune.stamina_cost

	for trigger_rune in trigger_rune_list:
		if trigger_rune == null:
			continue
		var is_rune_trigger : bool = trigger_rune_handler.check_is_rune_triggered(trigger_rune, skill_owner)
		if skill.type == skill.SkillType.AND_TRIGGER:
			is_skill_trigger = is_skill_trigger and is_rune_trigger
		elif skill.type == skill.SkillType.OR_TRIGGER:
			is_skill_trigger = is_skill_trigger or is_rune_trigger
		
		skill_stamina_cost += trigger_rune.stamina_cost
	
	if status_component:
		
		if is_skill_trigger and status_component.get_current_stamina() >= skill_stamina_cost:
			# print_debug(skill_owner.name, "释放了 ","技能：", skill.skill_id)
			status_component.reduce_stamina(skill_stamina_cost)
			# print_debug("精力减少：", skill_stamina_cost, "  现在的精力值为", status_component.get_current_stamina())
			
			var skill_handler = SkillCircleHandler.new(skill, skill_owner)
			skill_owner.add_child(skill_handler)
			return true

		else:
			if is_skill_trigger:
				UIManager.stamina_exhaust_tip_request.emit()
				# print_debug("没有足够的精力释放技能： ", skill.skill_id, " 当前精力：", status_component.get_current_stamina())
	
	return false
