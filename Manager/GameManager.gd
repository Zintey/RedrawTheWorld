extends Node

var run_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var current_seed: String = ""

# --- 核心控制变量 ---
@export var total_depth: int = 5      # 本局游戏的总深度
var current_depth: int = 1
var level_history: Array[LevelData] = []
var current_level_data: LevelData

@export var debug_seed: String = "ZINTEY_RUN"
@export var debug_start_level: LevelData

func start_new_run(seed_str: String, starting_level: LevelData):
	current_seed = seed_str
	run_rng.seed = current_seed.hash()
	current_depth = 1
	level_history.clear()
	current_level_data = starting_level
	level_history.append(current_level_data)

func roll_next_level() -> LevelData:
	# 方案 A 逻辑：如果已经到达最后一层，就不再生成新的 LevelData，直接返回当前或触发结束逻辑
	if current_depth >= total_depth:
		print("GameManager: 已到达最终深度，不再进行关卡滚动。")
		return current_level_data

	var dict_weight_sum = 0
	for weight in current_level_data.next_level_pool.values():
		dict_weight_sum += weight
	
	var total_weight = current_level_data.self_loop_weight + dict_weight_sum

	if total_weight <= 0:
		current_depth += 1
		level_history.append(current_level_data)
		return current_level_data

	var roll = run_rng.randi_range(1, total_weight)
	
	# 自身循环判断
	if roll <= current_level_data.self_loop_weight:
		current_depth += 1
		level_history.append(current_level_data)
		return current_level_data

	# 抽取下一关
	var cumulative = current_level_data.self_loop_weight
	var next_level: LevelData = null
	for level_res in current_level_data.next_level_pool.keys():
		cumulative += current_level_data.next_level_pool[level_res]
		if roll <= cumulative:
			next_level = level_res
			break
			
	if next_level:
		current_depth += 1
		current_level_data = next_level
		level_history.append(current_level_data)
		
	return current_level_data

func pick_random_from_array(array: Array):
	if array.is_empty(): return null
	return array[run_rng.randi() % array.size()]