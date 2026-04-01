class_name SkillComponent extends Node

@export var skill_owner : PhysicsBody2D
@export var stats_component : PlayerStatsComponent
@export var inventory_component : InventoryComponent

var skill_list : Array[SkillData]
# var trigger_rune_handler : TriggerRuneHandler

# 【新增：黑板与CD系统】
var blackboard : Dictionary = {}	  # 记录当前发生的事件及剩余缓冲时间
var skill_cooldowns : Dictionary = {} # 记录每个技能(Resource)的当前剩余CD

func _ready() -> void:
	var owner_name: String = skill_owner.name if skill_owner else "未知节点"
	
	if stats_component == null:
		printerr(owner_name, " 的 SkillComponent 没有设置 stats_component 属性！")
	if inventory_component == null:
		printerr(owner_name, " 的 SkillComponent 没有设置 inventory_component 属性！")
	else:
		skill_list = inventory_component.equipped_skills

	# trigger_rune_handler = TriggerRuneHandler.new()

# 【新增】：向黑板发布事件（贴便签）
func post_event(event_name: String, duration: float) -> void:
	blackboard[event_name] = duration

func _physics_process(delta: float) -> void:
	# 1. 更新黑板便签的倒计时
	var expired_events = []
	for event in blackboard.keys():
		blackboard[event] -= delta
		if blackboard[event] <= 0:
			expired_events.append(event)
	for event in expired_events:
		blackboard.erase(event)
		
	# 2. 更新技能的冷却时间
	for skill in skill_cooldowns.keys():
		if skill_cooldowns[skill] > 0:
			skill_cooldowns[skill] -= delta
			
	# 3. 如果黑板上有事件，每帧去评估技能是否触发
	if not blackboard.is_empty():
		check_skills_triggered()

func check_skills_triggered() -> void:
	if !skill_owner.stats_component.has_emitter:
		return
		
	for skill in skill_list:
		if skill == null:
			continue
			
		# 【CD拦截】：如果技能还在冷却中，直接跳过
		if skill_cooldowns.get(skill, 0.0) > 0.0:
			continue
			
		var is_triggered : bool = check_skill_triggered(skill)
		
		if is_triggered:
			# 【新增】：精算最终冷却时间，最小锁死为 0.1 秒
			var cd_add = 0.0
			var cd_mult = 1.0
			
			for r in skill.trigger_rune_list:
				if r: cd_add += r.cooldown_add; cd_mult *= r.cooldown_multiple
			for r in skill.core_rune_list:
				if r: cd_add += r.cooldown_add; cd_mult *= r.cooldown_multiple
			for r in skill.modifier_rune_list:
				if r: cd_add += r.cooldown_add; cd_mult *= r.cooldown_multiple
				
			var final_cd = max(0.1, (skill.base_cooldown + cd_add) * cd_mult)
			
			# 触发成功，进入最终算出的CD
			skill_cooldowns[skill] = final_cd
			
			# 生成法术工厂并直接调用发射器
			var skill_circle = SkillCircleHandler.new(skill, skill_owner)
			add_child(skill_circle)
			skill_owner.rune_emitter.fire(skill)

func check_skill_triggered(skill : SkillData) -> bool:
	# 【修复 1：核心符文拦截】检查是否装备了核心符文，如果没有，绝对不允许发动！
	var has_core = false
	for rune in skill.core_rune_list:
		if rune != null:
			has_core = true
			break
	if not has_core:
		return false # 没有核心符文，直接哑火
		
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
		
		# 将黑板字典传给逻辑处理器
		# var is_rune_trigger : bool = trigger_rune_handler.check_is_rune_triggered(trigger_rune, blackboard, skill_owner)
		var is_rune_trigger : bool = blackboard.has(trigger_rune.blackboard)

		if skill.type == skill.SkillType.AND_TRIGGER:
			is_skill_trigger = is_skill_trigger and is_rune_trigger
		elif skill.type == skill.SkillType.OR_TRIGGER:
			is_skill_trigger = is_skill_trigger or is_rune_trigger
		
		skill_stamina_cost += trigger_rune.stamina_cost
		skill_stamina_cost_multiple *= trigger_rune.stamina_cost_multiple
	
	if stats_component:
		# 【修复 2：精力扣除 Bug】算出最终消耗，扣除时严格带上倍率！
		var final_cost = skill_stamina_cost * skill_stamina_cost_multiple
		
		if is_skill_trigger:
			if stats_component.current_stamina >= final_cost:
				stats_component.reduce_stamina(final_cost) 
				return true
			else:
				post_event("stamina_empty", 0.1)
			
	return false