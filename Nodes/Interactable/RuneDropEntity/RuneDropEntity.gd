class_name RuneDropEntity extends RigidBody2D

@export var rune_data: RuneData

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable_area: InteractableArea = $InteractableArea

# 【已移除】：移除 time_passed 变量

func _ready() -> void:
	if rune_data:
		# 【核心修复】：如果是场景里手动摆放的掉落物，深拷贝切断绑定！
		rune_data = rune_data.duplicate(true)
		sprite.texture = rune_data.icon 
		
	sprite.position = Vector2.ZERO
		
	# 监听交互信号
	interactable_area.focused.connect(_on_focused)
	interactable_area.unfocused.connect(_on_unfocused)
	interactable_area.interacted.connect(_on_interacted)
	
	# 出生抛物线冲击
	apply_central_impulse(Vector2(randf_range(-150, 150), randf_range(-300, -450)))

# 【已移除】：彻底移除 _process 函数及其内部的 sin() 浮动逻辑

func _on_focused() -> void:
	# 保留高光
	sprite.modulate = Color(1.5, 1.5, 1.5) 
	UIManager.rune_world_brief_requested.emit(rune_data, self)
	
func _on_unfocused() -> void:
	sprite.modulate = Color.WHITE
	UIManager.rune_brief_closed.emit()

func _on_interacted(interactor: Node2D) -> void:
	var inventory = interactor.get_node_or_null("InventoryComponent")
	if inventory:
		if inventory.add_rune(rune_data):
			# 成功拾取逻辑
			UIManager.rune_brief_closed.emit()
			freeze = true 
			interactable_area.queue_free()
			
			var tween = create_tween()
			tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
			tween.parallel().tween_property(sprite, "global_position", interactor.global_position, 0.2)
			tween.tween_callback(queue_free)
		else:
			# 满载逻辑
			# (这里需要预加载 floating_text.tscn)
			var ft = preload("uid://b31y5clrg6ecu").instantiate()
			get_tree().current_scene.add_child(ft)
			ft.global_position = global_position + Vector2(0, -20)
			ft.start("背包已满！", Color(1.0, 0.2, 0.2))