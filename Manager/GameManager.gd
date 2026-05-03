extends Node

# 各系统专用的随机数生成器，分开是为了让 seed 互不干扰
# 同一个 seed 跑同一局，地图/商店/掉落结果都能完全复现
var run_rng: RandomNumberGenerator = RandomNumberGenerator.new()   # 通用随机，没有明确归属的地方用这个
var map_rng: RandomNumberGenerator = RandomNumberGenerator.new()   # 地图生成专用
var shop_rng: RandomNumberGenerator = RandomNumberGenerator.new()  # 商店刷新专用
var drop_rng: RandomNumberGenerator = RandomNumberGenerator.new()  # 掉落专用

var current_seed: String = ""  # 当前局的种子字符串，保存下来方便每层重新算 rng

@export var total_depth: int = 5   # 一局总共几层，编辑器里改
var current_depth: int = 1         # 当前所在层数
var level_history: Array[LevelData] = []  # 走过的关卡记录，方便回溯或展示路径
var current_level_data: LevelData         # 当前这层用的关卡配置

@export var debug_seed: String = "GAME_SEED123"  # 调试用固定种子
@export var debug_start_level: LevelData         # 调试用起始关卡


# 开启新一局游戏，传入种子和起始关卡配置
# 会重置深度、历史记录，并根据种子初始化所有 rng
func start_new_run(seed_str: String, starting_level: LevelData):
	current_seed = seed_str
	current_depth = 1
	_update_all_rngs()
	
	level_history.clear()
	current_level_data = starting_level
	level_history.append(current_level_data)

# 根据当前 seed + 层数，重新算出各系统的 rng 初始值
# 每进一层都要调一次，确保不同层的随机结果彼此独立
func _update_all_rngs() -> void:
	var base_hash = current_seed.hash()
	run_rng.seed = base_hash 
	map_rng.seed = str(current_seed + "_map_level_" + str(current_depth)).hash()
	shop_rng.seed = str(current_seed + "_shop_level_" + str(current_depth)).hash()
	drop_rng.seed = str(current_seed + "_drop_level_" + str(current_depth)).hash()

# 按当前关卡配置的权重表，随机抽出下一层要去哪个关卡
# 支持"原地循环"（self_loop_weight）和跳转到其他关卡两种结果
# 已到最终层则直接返回当前关卡，不再推进
func roll_next_level() -> LevelData:
	if current_depth >= total_depth:
		print("GameManager: 已到达最终深度")
		return current_level_data

	var dict_weight_sum = 0
	for weight in current_level_data.next_level_pool.values():
		dict_weight_sum += weight
	
	var total_weight = current_level_data.self_loop_weight + dict_weight_sum

	# 权重全是 0 的话没法抽，直接原地留着就好
	if total_weight <= 0:
		_advance_depth_and_record(current_level_data)
		return current_level_data

	var roll = map_rng.randi_range(1, total_weight)
	
	# roll 落在 self_loop 区间就留在当前关卡
	if roll <= current_level_data.self_loop_weight:
		_advance_depth_and_record(current_level_data)
		return current_level_data

	# 否则按权重顺序找对应的下一关
	var cumulative = current_level_data.self_loop_weight
	var next_level: LevelData = null
	for level_res in current_level_data.next_level_pool.keys():
		cumulative += current_level_data.next_level_pool[level_res]
		if roll <= cumulative:
			next_level = level_res
			break
			
	if next_level:
		_advance_depth_and_record(next_level)
		
	return current_level_data

# 推进一层：深度 +1，更新当前关卡，写进历史，刷新 rng
func _advance_depth_and_record(level: LevelData) -> void:
	current_depth += 1
	current_level_data = level
	level_history.append(current_level_data)
	_update_all_rngs()

# 从数组里随机取一个元素，默认用 run_rng
# 传空数组返回 null，外部记得判断
func pick_random_from_array(array: Array, rng: RandomNumberGenerator = run_rng):
	if array.is_empty(): return null
	return array[rng.randi() % array.size()]