class_name SkillDropEntity extends RigidBody2D

@export var skill_data: SkillData

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable_area: InteractableArea = $InteractableArea

func _ready() -> void:
	if skill_data:
		# 【核心修复】：如果是场景里手动摆放的掉落物，深拷贝切断绑定！
		skill_data = skill_data.duplicate(true)
		sprite.texture = skill_data.skill_icon 
		
	sprite.position = Vector2.ZERO
		
	# 监听雷达塔传来的交互信号
	interactable_area.focused.connect(_on_focused)
	interactable_area.unfocused.connect(_on_unfocused)
	interactable_area.interacted.connect(_on_interacted)
	
	# 爆出宝箱的物理抛物线
	apply_central_impulse(Vector2(randf_range(-150, 150), randf_range(-300, -450)))

func _on_focused() -> void:
	sprite.modulate = Color(1.5, 1.5, 1.5)
	# 呼叫 EventBus
	EventBus.skill_world_brief_requested.emit(skill_data, self)
	
func _on_unfocused() -> void:
	sprite.modulate = Color.WHITE
	# 呼叫 EventBus
	EventBus.skill_world_brief_closed.emit()

func _on_interacted(interactor: Node2D) -> void:
	var inventory = interactor.get_node_or_null("InventoryComponent")
	if inventory:
		if inventory.add_skill(skill_data):
			# 拾取成功，呼叫 EventBus 关闭 UI
			EventBus.skill_world_brief_closed.emit()
			
			freeze = true 
			interactable_area.queue_free() 
			
			var tween = create_tween()
			tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
			tween.parallel().tween_property(sprite, "global_position", interactor.global_position, 0.2)
			tween.tween_callback(queue_free)
		else:
			_show_dynamic_floating_text("工作台已满！", Color(1.0, 0.2, 0.2))

# 【极客函数】：凭空捏造一个漂浮文字，用完即毁
func _show_dynamic_floating_text(msg: String, text_color: Color) -> void:
	var label = Label.new()
	label.text = msg
	label.modulate = text_color
	# 加个黑边，保证在任何复杂的像素背景下都能看清
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 12)
	
	# 强行塞入当前游戏世界的根节点下，与实体解绑
	get_tree().current_scene.add_child(label)
	
	# 居中对齐在实体头上
	label.global_position = global_position + Vector2(-label.size.x / 2.0, -25)
	
	# 果汁感：上浮 + 渐隐
	var tween = create_tween()
	tween.tween_property(label, "global_position:y", label.global_position.y - 40, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free) # 飘完自动魂飞魄散