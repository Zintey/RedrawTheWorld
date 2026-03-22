class_name SkillBriefUI
extends Control

@export var skill_data : SkillData
@onready var skill_name_label: Label = %SkillNameLabel
@onready var skill_description_label: RichTextLabel = %SkillDescriptionLabel 

const COLOR_TRIGGER = "#ffcc00" 
const COLOR_CORE = "#9933ff"    
const COLOR_MODIFIER = "#aaaaaa" 

func init(_skill_data : SkillData) -> void:
	skill_data = _skill_data
	update_ui()

func _process(delta: float) -> void:
	var current_position = Vector2(min(get_global_mouse_position().x, get_viewport_rect().size.x - size.x), 
	min(get_global_mouse_position().y, get_viewport_rect().size.y - size.y))
	global_position = current_position

func _ready():
	z_index = 4000
	update_ui()

func update_ui() -> void:
	if skill_data != null and is_node_ready():
		skill_name_label.text = skill_data.skill_name
		
		# === 精力结算变量 ===
		var final_cost = 0.0
		var final_mult = 1.0
		var base_str = ""
		var mult_str = ""
		
		# === 冷却结算变量 ===
		var final_cd_add = 0.0
		var final_cd_mult = 1.0
		var cd_base_str = "基础 " + str(skill_data.base_cooldown)
		var cd_mult_str = ""
		
		var all_runes = [
			{"list": skill_data.trigger_rune_list, "color": COLOR_TRIGGER},
			{"list": skill_data.core_rune_list, "color": COLOR_CORE},
			{"list": skill_data.modifier_rune_list, "color": COLOR_MODIFIER}
		]
		
		for group in all_runes:
			for r in group.list:
				if r != null:
					# 精力计算
					base_str += " + [color=" + group.color + "]" + str(r.stamina_cost) + "[/color]"
					final_cost += r.stamina_cost
					if r.stamina_cost_multiple != 1.0:
						mult_str += " * [color=" + group.color + "]" + str(r.stamina_cost_multiple) + "[/color]"
						final_mult *= r.stamina_cost_multiple
						
					# 冷却计算
					cd_base_str += " + [color=" + group.color + "]" + str(r.cooldown_add) + "[/color]"
					final_cd_add += r.cooldown_add
					if r.cooldown_multiple != 1.0:
						cd_mult_str += " * [color=" + group.color + "]" + str(r.cooldown_multiple) + "[/color]"
						final_cd_mult *= r.cooldown_multiple
					
		if base_str.begins_with(" + "): base_str = base_str.substr(3)
		if base_str == "": base_str = "0"
			
		var calculated_cost = final_cost * final_mult
		var calculated_cd = max(0.1, (skill_data.base_cooldown + final_cd_add) * final_cd_mult)
		
		var formula_text = "[color=yellow]精力消耗结算：[/color]\n"
		formula_text += "(" + base_str + ")" + mult_str + "\n"
		formula_text += "[color=cyan]▶ 最终扣除 = " + str(snapped(calculated_cost, 0.1)) + "[/color]\n\n"
		
		formula_text += "[color=yellow]冷却时间结算：[/color]\n"
		formula_text += "(" + cd_base_str + ")" + cd_mult_str + "\n"
		formula_text += "[color=cyan]▶ 最终冷却 = " + str(snapped(calculated_cd, 0.01)) + " 秒[/color]\n\n"
		
		formula_text += "[color=gray]" + skill_data.skill_description + "[/color]"
		skill_description_label.text = formula_text