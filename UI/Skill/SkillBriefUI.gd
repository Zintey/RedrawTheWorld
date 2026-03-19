class_name SkillBriefUI
extends Control

@export var skill_data : SkillData
@onready var skill_name_label: Label = %SkillNameLabel
@onready var skill_description_label: RichTextLabel = %SkillDescriptionLabel 

# 你的专属调色板
const COLOR_TRIGGER = "#ffcc00" # 黄色
const COLOR_CORE = "#9933ff"    # 紫色
const COLOR_MODIFIER = "#aaaaaa" # 灰色

func init(_skill_data : SkillData) -> void:
	skill_data = _skill_data
	update_ui()

func _process(delta: float) -> void:
	var current_position = Vector2(min(get_global_mouse_position().x, get_viewport_rect().size.x - size.x), 
	min(get_global_mouse_position().y, get_viewport_rect().size.y - size.y))
	global_position = current_position

func _ready():
	z_index = 10000
	update_ui()

func update_ui() -> void:
	if skill_data != null and is_node_ready():
		skill_name_label.text = skill_data.skill_name
		
		var final_cost = 0.0
		var final_mult = 1.0
		var base_str = ""
		var mult_str = ""
		
		# 触发 (黄)
		for r in skill_data.trigger_rune_list:
			if r != null:
				base_str += " + [color=" + COLOR_TRIGGER + "]" + str(r.stamina_cost) + "[/color]"
				final_cost += r.stamina_cost
				if r.stamina_cost_multiple != 1.0:
					mult_str += " * [color=" + COLOR_TRIGGER + "]" + str(r.stamina_cost_multiple) + "[/color]"
					final_mult *= r.stamina_cost_multiple
		
		# 核心 (紫)
		for r in skill_data.core_rune_list:
			if r != null:
				base_str += " + [color=" + COLOR_CORE + "]" + str(r.stamina_cost) + "[/color]"
				final_cost += r.stamina_cost
				if r.stamina_cost_multiple != 1.0:
					mult_str += " * [color=" + COLOR_CORE + "]" + str(r.stamina_cost_multiple) + "[/color]"
					final_mult *= r.stamina_cost_multiple

		# 辅助 (灰)
		for r in skill_data.modifier_rune_list:
			if r != null:
				base_str += " + [color=" + COLOR_MODIFIER + "]" + str(r.stamina_cost) + "[/color]"
				final_cost += r.stamina_cost
				if r.stamina_cost_multiple != 1.0:
					mult_str += " * [color=" + COLOR_MODIFIER + "]" + str(r.stamina_cost_multiple) + "[/color]"
					final_mult *= r.stamina_cost_multiple
					
		if base_str.begins_with(" + "):
			base_str = base_str.substr(3)
		if base_str == "":
			base_str = "0"
			
		var calculated_cost = final_cost * final_mult
		
		var formula_text = "[color=yellow]精力消耗结算：[/color]\n"
		formula_text += "(" + base_str + ")" + mult_str + "\n"
		formula_text += "[color=cyan]▶ 最终扣除 = " + str(calculated_cost) + "[/color]\n\n"
		formula_text += "[color=gray]" + skill_data.skill_description + "[/color]"
		
		skill_description_label.text = formula_text
