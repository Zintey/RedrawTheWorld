class_name RuneBriefUI
extends Control

@export var rune_data : RuneData
@onready var rune_name_label: Label = %RuneNameLabel
@onready var rune_description_label: RichTextLabel = %RuneDescriptionLabel
@onready var stamina_cost_label: Label = %StaminaCostLabel

var world_target: Node2D = null

const COLOR_TRIGGER = "#ffcc00" 
const COLOR_CORE = "#9933ff"    
const COLOR_MODIFIER = "#aaaaaa" 

func init(_rune_data : RuneData, _world_target: Node2D = null) -> void:
	rune_data = _rune_data
	world_target = _world_target
	update_ui()

func _process(delta: float) -> void:
	if is_instance_valid(world_target):
		# 1. 转换屏幕坐标
		var screen_pos = world_target.get_global_transform_with_canvas().origin

		# === 【核心修复】：精算水平与垂直偏移 ===
		# global_position 设置的是 UI 的左上角。
		# 我们需要在 X 轴上，向左移半个 UI 的宽度 (-size.x / 2.0)。
		# 在 Y 轴上，向上移整个 UI 的高度 (-size.y) 再加上一个和头顶的固定间距。
		var offset_x = -size.x / 2.0
		var offset_y = -size.y - 15.0 # -15 是飘在物体头顶的间距，可自行微调

		global_position = screen_pos + Vector2(offset_x, offset_y)
	else:
		# 保留原本的鼠标跟随逻辑 (也处理了边界拦截)
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