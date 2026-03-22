class_name CombatSkillSlotUI
extends VBoxContainer # 修改了根节点类型

@export var default_empty_icon: Texture2D

@onready var cost_label: Label = $CostLabel
@onready var icon_rect: TextureRect = $InnerPanel/Icon
@onready var warning_rect: ColorRect = $InnerPanel/WarningRect
@onready var cd_bar: TextureProgressBar = $InnerPanel/CooldownBar

func update_slot(skill_data: SkillData, current_cd: float, current_stamina: float) -> void:
	if skill_data == null:
		icon_rect.texture = default_empty_icon
		warning_rect.hide()
		cd_bar.value = 0
		cost_label.text = "" # 空技能不显示字
		return
		
	# 1. 动态加载核心符文图标
	var has_core = false
	for rune in skill_data.core_rune_list:
		if rune != null:
			icon_rect.texture = rune.icon
			has_core = true
			break
	if not has_core:
		icon_rect.texture = default_empty_icon
		
	# 2. 预先算出完整数据
	var cost = 0.0
	var mult = 1.0
	var cd_add = 0.0
	var cd_mult = 1.0
	
	for r in skill_data.trigger_rune_list:
		if r: cost += r.stamina_cost; mult *= r.stamina_cost_multiple; cd_add += r.cooldown_add; cd_mult *= r.cooldown_multiple
	for r in skill_data.core_rune_list:
		if r: cost += r.stamina_cost; mult *= r.stamina_cost_multiple; cd_add += r.cooldown_add; cd_mult *= r.cooldown_multiple
	for r in skill_data.modifier_rune_list:
		if r: cost += r.stamina_cost; mult *= r.stamina_cost_multiple; cd_add += r.cooldown_add; cd_mult *= r.cooldown_multiple
		
	var total_cost = cost * mult
	var final_cd = max(0.1, (skill_data.base_cooldown + cd_add) * cd_mult)
	
	# 3. 方案A：更新格子上方的精力文本，保留1位小数
	cost_label.text = str(snapped(total_cost, 0.1))
	
	# 4. 扇形 CD 遮罩
	if current_cd > 0:
		cd_bar.value = (current_cd / final_cd) * 100.0
	else:
		cd_bar.value = 0
		
	# 5. 精力不足红底警示
	if current_stamina < total_cost and current_cd <= 0:
		warning_rect.show()
	else:
		warning_rect.hide()