class_name ShopCounter extends Node2D

var item_data: ItemData
var price: int = 0
var is_sold_out: bool = false
var time_passed: float = 0.0 # 用于处理悬浮动画的时间累加

@onready var item_sprite: Sprite2D = $ItemSprite
@onready var price_label: Label = $PriceLabel
@onready var interactable_area: InteractableArea = $InteractableArea
@onready var brief_marker: Marker2D = $BriefMarker

var item_sprite_origin_position_y


func _ready() -> void:
	item_sprite_origin_position_y = item_sprite.position.y

# 接收店长的进货数据
func set_item(_data: ItemData, current_depth: int) -> void:
	# 【核心修复】：深拷贝！强行切断与源文件的灵魂绑定，让这件商品变成独一无二的实体！
	item_data = _data.duplicate(true) 
	
	item_sprite.texture = item_data.icon
	
	price = PriceManager.get_item_price(item_data, current_depth)
	price_label.text = str(price) + " G"
	
	time_passed = randf() * 10.0 
	
	interactable_area.focused.connect(_on_focused)
	interactable_area.unfocused.connect(_on_unfocused)
	interactable_area.interacted.connect(_on_interacted)

func _process(delta: float) -> void:
	# 纯视觉悬浮动画
	if not is_sold_out and item_sprite.texture:
		time_passed += delta
		item_sprite.position.y = item_sprite_origin_position_y + sin(time_passed * 2.0) * 3.0

func _on_focused() -> void:
	if is_sold_out: return
	item_sprite.modulate = Color(1.5, 1.5, 1.5)
	
	# 这里根据需要呼叫EventBus弹出不同的UI
	if item_data is RuneData: 
		EventBus.rune_world_brief_requested.emit(item_data, brief_marker)
	elif item_data is SkillData: EventBus.skill_world_brief_requested.emit(item_data, brief_marker)

func _on_unfocused() -> void:
	if is_sold_out: return
	item_sprite.modulate = Color.WHITE
	
	if item_data is RuneData: UIManager.rune_brief_closed.emit()
	elif item_data is SkillData: EventBus.skill_world_brief_closed.emit()

func _on_interacted(interactor: Node2D) -> void:
	if is_sold_out: return
	
	var stats = interactor.get_node_or_null("PlayerStatsComponent")
	if not stats: return
	
	# 【防线1：验资】
	if stats.current_gold < price:
		_show_floating_text("金币不足！", Color(1.0, 0.2, 0.2))
		return
		
	# 【防线2：多态策略装载】柜台闭着眼睛直接呼叫基类方法
	if item_data.apply_effect(interactor):
		# 成功 -> 扣钱，关 UI，打烊
		stats.spend_gold(price)
		
		if item_data is RuneData: UIManager.rune_brief_closed.emit()
		elif item_data is SkillData: EventBus.skill_world_brief_closed.emit()
		
		_execute_sold_out(interactor.global_position)
	else:
		# 失败（满了） -> 拒绝扣款
		_show_floating_text("空间已满！", Color(1.0, 0.2, 0.2))

func _execute_sold_out(player_pos: Vector2) -> void:
	is_sold_out = true
	interactable_area.queue_free() # 彻底废弃雷达
	price_label.text = ""
	price_label.modulate = Color.GRAY
	
	# 飞入体内的果汁感动画
	var tween = create_tween()
	tween.tween_property(item_sprite, "scale", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(item_sprite, "global_position", player_pos, 0.2)
	tween.tween_callback(item_sprite.hide)

func _show_floating_text(msg: String, color: Color) -> void:
	var label = Label.new()
	label.text = msg
	label.modulate = color
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.z_index = 1

	get_tree().current_scene.add_child(label)
	label.global_position = global_position + Vector2(-20, -40)
	
	var tween = create_tween()
	tween.tween_property(label, "global_position:y", label.global_position.y - 40, 1.0).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)
