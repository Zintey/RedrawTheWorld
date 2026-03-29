extends Node

# --- 多路并发 RNG 矩阵 ---
var run_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var map_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var shop_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var drop_rng: RandomNumberGenerator = RandomNumberGenerator.new()

var current_seed: String = ""

# --- 核心控制变量 ---
@export var total_depth: int = 5      # 本局游戏的总深度
var current_depth: int = 1
var level_history: Array[LevelData] = []
var current_level_data: LevelData

@export var debug_seed: String = "GAME_SEED123"
@export var debug_start_level: LevelData


func start_new_run(seed_str: String, starting_level: LevelData):
	current_seed = seed_str
	current_depth = 1
	_update_all_rngs() # 核心：初始化多路RNG
	
	level_history.clear()
	current_level_data = starting_level
	level_history.append(current_level_data)

# 【核心防护】：每次切层/初始化时，重新派生子种子，彻底杜绝跨系统污染
func _update_all_rngs() -> void:
	var base_hash = current_seed.hash()
	run_rng.seed = base_hash 
	map_rng.seed = str(current_seed + "_map_level_" + str(current_depth)).hash()
	shop_rng.seed = str(current_seed + "_shop_level_" + str(current_depth)).hash()
	drop_rng.seed = str(current_seed + "_drop_level_" + str(current_depth)).hash()

func roll_next_level() -> LevelData:
	if current_depth >= total_depth:
		print("GameManager: 已到达最终深度，不再进行关卡滚动。")
		return current_level_data

	var dict_weight_sum = 0
	for weight in current_level_data.next_level_pool.values():
		dict_weight_sum += weight
	
	var total_weight = current_level_data.self_loop_weight + dict_weight_sum

	if total_weight <= 0:
		_advance_depth_and_record(current_level_data)
		return current_level_data

	# 【修改】：关卡路由使用专属的 map_rng
	var roll = map_rng.randi_range(1, total_weight)
	
	if roll <= current_level_data.self_loop_weight:
		_advance_depth_and_record(current_level_data)
		return current_level_data

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

func _advance_depth_and_record(level: LevelData) -> void:
	current_depth += 1
	current_level_data = level
	level_history.append(current_level_data)
	_update_all_rngs() # 每次深度加 1，所有 RNG 重新上膛！

# 【修改】：通用抽取函数，允许传入特定的 rng（默认 run_rng 兜底）
func pick_random_from_array(array: Array, rng: RandomNumberGenerator = run_rng):
	if array.is_empty(): return null
	return array[rng.randi() % array.size()]
