class_name CombatActionBarUI
extends Control

@onready var grid: GridContainer = $GridContainer
var slots: Array[CombatSkillSlotUI] = []

var skill_component: SkillComponent
var stats_component: PlayerStatsComponent

func init(sk_comp: SkillComponent, st_comp: PlayerStatsComponent) -> void:
	skill_component = sk_comp
	stats_component = st_comp

func _ready() -> void:
	for child in grid.get_children():
		if child is CombatSkillSlotUI:
			slots.append(child)

# 暴力且高效的轮询，彻底解耦
func _process(delta: float) -> void:
	if not is_instance_valid(skill_component) or not is_instance_valid(stats_component):
		return
		
	var skills = skill_component.skill_list
	var stamina = stats_component.current_stamina
	var cds = skill_component.skill_cooldowns
	
	for i in range(slots.size()):
		if i < skills.size():
			var sk = skills[i]
			var cd = cds.get(sk, 0.0) if sk else 0.0
			slots[i].update_slot(sk, cd, stamina)
		else:
			slots[i].update_slot(null, 0.0, stamina)