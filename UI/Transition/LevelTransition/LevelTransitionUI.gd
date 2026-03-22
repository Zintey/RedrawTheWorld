extends Control
class_name LevelTransitionUI

@onready var bg_rect: ColorRect = $ColorRect
@onready var icon_container: HBoxContainer = %IconContainer
@onready var level_name_label: Label = %LevelNameLabel

# --- 新增导出变量：允许指定未来层的占位图标 ---
@export var unknown_icon: Texture2D

var is_initial_start: bool = false

func _ready():
	bg_rect.modulate.a = 0.0
	level_name_label.modulate.a = 0.0

func init_transition(initial: bool):
	is_initial_start = initial
	_play_transition()

func _play_transition():
	var tween = create_tween()
	tween.tween_property(bg_rect, "modulate:a", 1.0, 0.5)
	
	tween.tween_callback(func():
		if not is_initial_start:
			GameManager.roll_next_level()
		_update_icons()
		var l_name = GameManager.current_level_data.level_name if GameManager.current_level_data else "Unknown"
		level_name_label.text = "层数 " + str(GameManager.current_depth) + " : " + l_name
	)
	
	tween.tween_property(level_name_label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5) 
	tween.tween_property(level_name_label, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		if is_initial_start:
			EventBus.ready_to_change_scene.emit() 
		else:
			EventBus.execute_map_rebuild.emit()   
	)
	
	await EventBus.map_rebuild_finished
	var fade_out = create_tween()
	fade_out.tween_property(bg_rect, "modulate:a", 0.0, 0.5)
	fade_out.tween_callback(self.queue_free)

# 根据 GameManager 的总深度渲染图标
func _update_icons():
	for child in icon_container.get_children():
		child.queue_free()
		
	# 绘制已完成和当前关卡的 Icon
	for i in range(GameManager.level_history.size()):
		var level = GameManager.level_history[i]
		var texture_rect = TextureRect.new()
		texture_rect.texture = level.level_icon
		texture_rect.custom_minimum_size = Vector2(64, 64)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		# 如果是当前深度，可以稍微调亮或放大（可选演出）
		if i != GameManager.current_depth - 1:
			texture_rect.modulate = Color(0.2, 0.2, 0.2) 
		icon_container.add_child(texture_rect)
		
	# 根据总深度补全未来的“问号”层
	var future_levels = GameManager.total_depth - GameManager.current_depth
	for i in range(future_levels):
		var q_rect = TextureRect.new()
		q_rect.texture = unknown_icon # 使用指定的占位图
		q_rect.custom_minimum_size = Vector2(64, 64)
		q_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		q_rect.modulate = Color(0.3, 0.3, 0.3, 0.8) # 变暗处理
		icon_container.add_child(q_rect)