class_name SkillComponent extends Node

@export var skill_owner : PhysicsBody2D
@export var stats_component : PlayerStatsComponent
@export var inventory_component : InventoryComponent

var skill_list : Array[SkillData]
var blackboard : Dictionary = {}
var skill_cooldowns : Dictionary = {}

func _ready() -> void:
	var owner_name: String = skill_owner.name if skill_owner else "未知节点"
	
	if stats_component == null:
		printerr(owner_name, " 的 SkillComponent 没有设置 stats_component 属性！")
	if inventory_component == null:
		printerr(owner_name, " 的 SkillComponent 没有设置 inventory_component 属性！")
	else:
		skill_list = inventory_component.equipped_skills

func post_event(event_name: String, duration: float) -> void:
	blackboard[event_name] = duration

func _physics_process(delta: float) -> void:
	var expired_events = []
	for event in blackboard.keys():
		blackboard[event] -= delta
		if blackboard[event] <= 0:
			expired_events.append(event)
	for event in expired_events:
		blackboard.erase(event)
		
	for skill in skill_cooldowns.keys():
		if skill_cooldowns[skill] > 0:
			skill_cooldowns[skill] -= delta
			
	if not blackboard.is_empty():
		check_skills_triggered()

func check_skills_triggered() -> void:
	if !skill_owner.stats_component.has_emitter:
		return
		
	for skill in skill_list:
		if skill == null:
			continue
			
		if skill_cooldowns.get(skill, 0.0) > 0.0:
			continue
			
		var is_triggered : bool = check_skill_triggered(skill)
		
		if is_triggered:
			var cd_add = 0.0
			var cd_mult = 1.0
			
			for r in skill.trigger_rune_list:
				if r: cd_add += r.cooldown_add; cd_mult *= r.cooldown_multiple
			for r in skill.core_rune_list:
				if r: cd_add += r.cooldown_add; cd_mult *= r.cooldown_multiple
			for r in skill.modifier_rune_list:
				if r: cd_add += r.cooldown_add; cd_mult *= r.cooldown_multiple
				
			var final_cd = max(0.1, (skill.base_cooldown + cd_add) * cd_mult)
			
			skill_cooldowns[skill] = final_cd
			
			var skill_circle = SkillCircleHandler.new(skill, skill_owner)
			add_child(skill_circle)
			skill_owner.rune_emitter.fire(skill)

func check_skill_triggered(skill : SkillData) -> bool:
	var has_core = false
	for rune in skill.core_rune_list:
		if rune != null:
			has_core = true
			break
	if not has_core:
		return false
		
	var trigger_rune_list : Array[RuneData] = skill.trigger_rune_list
	var is_skill_trigger : bool = true if skill.type == skill.SkillType.AND_TRIGGER else false
	var skill_stamina_cost : float = 0.0
	var skill_stamina_cost_multiple : float = 1.0
	
	for rune in skill.modifier_rune_list:
		if rune == null: continue
		skill_stamina_cost += rune.stamina_cost
		skill_stamina_cost_multiple *= rune.stamina_cost_multiple
	
	for rune in skill.core_rune_list:
		if rune == null: continue
		skill_stamina_cost += rune.stamina_cost
		skill_stamina_cost_multiple *= rune.stamina_cost_multiple

	for trigger_rune in trigger_rune_list:
		if trigger_rune == null: continue
		
		var is_rune_trigger : bool = blackboard.has(trigger_rune.blackboard)

		if skill.type == skill.SkillType.AND_TRIGGER:
			is_skill_trigger = is_skill_trigger and is_rune_trigger
		elif skill.type == skill.SkillType.OR_TRIGGER:
			is_skill_trigger = is_skill_trigger or is_rune_trigger
		
		skill_stamina_cost += trigger_rune.stamina_cost
		skill_stamina_cost_multiple *= trigger_rune.stamina_cost_multiple
	
	if stats_component:
		var final_cost = skill_stamina_cost * skill_stamina_cost_multiple
		
		if is_skill_trigger:
			if stats_component.current_stamina >= final_cost:
				stats_component.reduce_stamina(final_cost) 
				return true
			else:
				post_event("stamina_empty", 0.1)
			
	return false