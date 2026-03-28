extends Node

# --- 策划配置区：多级大盘 ---
# 建议在编辑器里暴露给策划配置，这里为了演示直接写死结构
@export var original_pools: Dictionary = {
	"tier_1": {
		"RUNE_POOL": [],  # 在 _ready 或 Inspector 里塞入一堆低级 RuneData
		"SKILL_POOL": []  # 塞入低级 SkillData
	},
	"tier_2": {
		"RUNE_POOL": [],  # 中级符文
		"SKILL_POOL": []  # 中级技能
	},
	"tier_3": {
		"RUNE_POOL": [],  # 神级符文
		"SKILL_POOL": []  # 神级技能
	}
}

# 兜底物品：当池子抽干时返回（比如一袋金币、一个血瓶）
@export var fallback_item: ItemData 

# --- 单局工作池 ---
var run_pools: Dictionary = {}

func _ready() -> void:
	init_run_pools()

# 【重要】：在 GameManager.start_new_run() 中必须调用此方法！
func init_run_pools() -> void:
	run_pools.clear()
	# 严谨的深拷贝结构，浅拷贝数组资源
	for tier in original_pools.keys():
		run_pools[tier] = {}
		for pool_name in original_pools[tier].keys():
			# duplicate(false) 保证生成的是新数组（抽卡不会影响原盘），但里面的资源依然是引用传递，节省内存
			run_pools[tier][pool_name] = original_pools[tier][pool_name].duplicate(false) 

# 店长专用的抽卡接口
func roll_shop_item(tier: String, pool_name: String) -> ItemData:
	# 检查池子是否枯竭或配置错误
	if not run_pools.has(tier) or not run_pools[tier].has(pool_name) or run_pools[tier][pool_name].is_empty():
		push_warning("LootManager: [%s] 的 [%s] 已抽干！触发兜底机制。" % [tier, pool_name])
		return fallback_item
		
	var pool: Array = run_pools[tier][pool_name]
	
	# 【核心】：强制使用 shop_rng 进行抽卡，隔离其他系统！
	var index = GameManager.shop_rng.randi() % pool.size() 
	var item = pool[index]
	
	# 【核心】：抽走即销毁，本局游戏绝不重复！
	pool.remove_at(index) 
	
	return item
