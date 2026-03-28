class_name ShopRoomController extends Node2D

@export var counter_scene: PackedScene # 把 ShopCounter.tscn 拖进来

# 本店的级别（对应 LootManager 的 tier）
@export var shop_tier: String = "tier_1"

# 【核心架构】：进货蓝图。数组的长度即代表展位的配置。
# 例如：1号展位 100%符文，2号展位 100%技能，3号展位 70%符文/30%技能
@export var blueprint: Array[Dictionary] = [
	{"RUNE_POOL": 100},
	{"SKILL_POOL": 100},
	{"RUNE_POOL": 70, "SKILL_POOL": 30}
]

@export var markers_parent: Node2D = self

func _ready() -> void:
	# 延迟一帧生成，确保 GameManager 和 LootManager 已经就绪
	call_deferred("_restock_shop")

func _restock_shop() -> void:
	var markers = markers_parent.get_children()
	
	# 按蓝图和实际 Marker 数量取最小值，防崩溃
	for i in range(min(blueprint.size(), markers.size())):
		var slot_weights = blueprint[i]
		
		# 1. 蓝图解析：抛骰子决定这个展位最终要什么类型的货
		var target_pool = _resolve_slot_pool(slot_weights)
		
		# 2. 向 LootManager 要货
		var item_data = LootManager.roll_shop_item(shop_tier, target_pool)
		if !item_data:
			print("item_data is null")
		if item_data and counter_scene:
			# 3. 动态实例化柜台
			var counter = counter_scene.instantiate() as ShopCounter
			markers[i].add_child(counter)
			
			# 4. 把数据交接给柜台
			counter.set_item(item_data, GameManager.current_depth)

# 蓝图权重解析器
func _resolve_slot_pool(weights: Dictionary) -> String:
	var total_weight = 0
	for w in weights.values():
		total_weight += w
		
	# 【核心】：蓝图权重的随机解析，必须使用 shop_rng！
	var roll = GameManager.shop_rng.randi_range(1, total_weight)
	
	var cumulative = 0
	for pool_name in weights.keys():
		cumulative += weights[pool_name]
		if roll <= cumulative:
			return pool_name
			
	return weights.keys()[0] # 理论上不会走到这里，兜底返回第一个
