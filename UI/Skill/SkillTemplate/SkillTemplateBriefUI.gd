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
	# 1. 实时获取屏幕的绝对宽高
	var viewport_size = get_viewport_rect().size
	var target_pos = Vector2.ZERO
	
	if is_instance_valid(world_target):
		var screen_pos = world_target.get_global_transform_with_canvas().origin
		var offset_x = -size.x / 2.0
		var offset_y = -size.y - 15.0 
		# 计算出理想的坐标
		target_pos = screen_pos + Vector2(offset_x, offset_y)
	else:
		# 鼠标跟随的理想坐标
		target_pos = get_global_mouse_position()

	# === 【核心修复】：边界绝对钳制 (Clamp) ===
	# X 轴：不能小于 0 (左边界)，不能大于 屏幕宽度减去自身宽度 (右边界)
	target_pos.x = clamp(target_pos.x, 0, viewport_size.x - size.x)
	# Y 轴：不能小于 0 (上边界)，不能大于 屏幕高度减去自身高度 (下边界)
	target_pos.y = clamp(target_pos.y, 0, viewport_size.y - size.y)
	
	global_position = target_pos

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