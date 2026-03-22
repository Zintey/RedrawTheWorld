class_name SkillTemplateBriefUI extends Control

@export var skill_data : SkillData
var world_target: Node2D = null 

@onready var skill_name_label: Label = %SkillNameLabel
@onready var base_prop_label: Label = %BasePropLabel
@onready var slots_rich_text: RichTextLabel = %SlotsRichText
@onready var desc_rich_text: RichTextLabel = %DescRichText

func init(_skill_data: SkillData, _world_target: Node2D = null) -> void:
	skill_data = _skill_data
	world_target = _world_target
	update_ui()

func _ready() -> void:
	z_index = 4000 # 确保显示在最上层
	update_ui()

func _process(delta: float) -> void:
	if is_instance_valid(world_target):
		var screen_pos = world_target.get_global_transform_with_canvas().origin
		var offset_x = -size.x / 2.0
		var offset_y = -size.y - 15.0 # 头顶间距
		global_position = screen_pos + Vector2(offset_x, offset_y)
	else:
		var current_position = Vector2(min(get_global_mouse_position().x, get_viewport_rect().size.x - size.x), 
		min(get_global_mouse_position().y, get_viewport_rect().size.y - size.y))
		global_position = current_position

func update_ui() -> void:
	if not skill_data or not is_node_ready(): return
	
	skill_name_label.text = skill_data.skill_name
	
	# 触发类型判断
	var type_str = "【联动触发型 (AND)】" if skill_data.type == SkillData.SkillType.AND_TRIGGER else "【独立触发型 (OR)】"
	base_prop_label.text = "基础冷却: " + str(skill_data.base_cooldown) + " 秒\n触发类型: " + type_str
	
	# === BBCode 小方块精妙排版 ===
	var slots_text = ""
	
	# 1. 触发槽 (黄色)
	slots_text += "触发槽: "
	for i in range(skill_data.trigger_rune_slot_count):
		slots_text += "[color=#ffcc00]■[/color] "
	slots_text += "\n"
	
	# 2. 核心槽 (紫色)
	slots_text += "核心槽: "
	for i in range(skill_data.core_rune_slot_count):
		slots_text += "[color=#9933ff]■[/color] "
	slots_text += "\n"
	
	# 3. 辅助槽 (灰色)
	slots_text += "辅助槽: "
	for i in range(skill_data.modifier_rune_slot_count):
		slots_text += "[color=#aaaaaa]■[/color] "
	
	slots_rich_text.text = slots_text
	desc_rich_text.text = "[color=gray]" + skill_data.skill_description + "[/color]"