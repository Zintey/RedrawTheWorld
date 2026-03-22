class_name RuneBriefUI
extends Control

@export var rune_data : RuneData
@onready var rune_name_label: Label = %RuneNameLabel
@onready var rune_description_label: RichTextLabel = %RuneDescriptionLabel
@onready var stamina_cost_label: Label = %StaminaCostLabel

const COLOR_TRIGGER = "#ffcc00" 
const COLOR_CORE = "#9933ff"    
const COLOR_MODIFIER = "#aaaaaa" 

func init(_rune_data : RuneData) -> void:
	rune_data = _rune_data
	update_ui() 

func _process(delta: float) -> void:
	var current_position = Vector2(min(get_global_mouse_position().x, get_viewport_rect().size.x - size.x), 
	min(get_global_mouse_position().y, get_viewport_rect().size.y - size.y))
	global_position = current_position

func _ready():
	z_index = 4000
	update_ui()

func update_ui() -> void:
	if rune_data != null and is_node_ready():
		rune_name_label.text = rune_data.display_name
		
		var cost_text = "能量消耗: " + str(rune_data.stamina_cost)
		if rune_data.stamina_cost_multiple != 1.0:
			cost_text += "  (倍率: x" + str(rune_data.stamina_cost_multiple) + ")"
			
		# 新增 CD 属性显示
		if rune_data.cooldown_add != 0.0 or rune_data.cooldown_multiple != 1.0:
			cost_text += "\n冷却补正: "
			if rune_data.cooldown_add != 0.0:
				cost_text += ("+" if rune_data.cooldown_add > 0 else "") + str(rune_data.cooldown_add) + "s  "
			if rune_data.cooldown_multiple != 1.0:
				cost_text += "(倍率: x" + str(rune_data.cooldown_multiple) + ")"
				
		stamina_cost_label.text = cost_text
		
		var type_str = ""
		match rune_data.type:
			RuneData.RuneType.TRIGGER: 
				type_str = "[color=" + COLOR_TRIGGER + "]【触发符文】[/color]"
				rune_name_label.modulate = Color(COLOR_TRIGGER)
			RuneData.RuneType.CORE: 
				type_str = "[color=" + COLOR_CORE + "]【核心符文】[/color]"
				rune_name_label.modulate = Color(COLOR_CORE)
			RuneData.RuneType.MODIFIER: 
				type_str = "[color=" + COLOR_MODIFIER + "]【辅助符文】[/color]"
				rune_name_label.modulate = Color(COLOR_MODIFIER)
			_: 
				type_str = "[color=white]【通用符文】[/color]"
				rune_name_label.modulate = Color.WHITE
		
		var desc = type_str + "\n\n[color=gray]" + rune_data.description + "[/color]"
		rune_description_label.text = desc