extends RefCounted
class_name Map

var room_types : Dictionary = {} # 记录索引到类型的映射 { index: "attack" }

const mx : Array[int] = [0, 0, -1, 1]
const my : Array[int] = [-1, 1, 0, 0]

class Edge:
	var v : int
	var next : int

var head : Array[int] = []
var edges : Array[Edge] = []
var points : Array[Vector2i] = []
var point_map : Dictionary = {}

var target_room_cnt : int = 0
var target_leaf_cnt : int = 0

func generate_map(config : Dictionary) -> Map:
	# 1. 必须调用 randomize()，确保每次运行种子不同
	randomize() 
	
	_reset()
	room_types.clear()
	target_room_cnt = config.get("room_cnt", 20)
	target_leaf_cnt = config.get("leaf_cnt", 5)
	
	# 边界检查
	if target_room_cnt < 1: target_room_cnt = 1
	target_leaf_cnt = clamp(target_leaf_cnt, 1, target_room_cnt)
	
	_generate_core()
	return self

func _reset():
	edges.clear()
	points.clear()
	point_map.clear()
	head.clear()

func _generate_core():
	# --- 修改点：只固定原点，不固定第二个点 ---
	var p1 = Vector2i(0, 0)
	_add_point(p1)
	
	var leaves = [0]
	var internals = []
	var current_count = 1 # 当前已有 1 个房间
	
	while current_count < target_room_cnt:
		var parent_idx : int = -1
		var can_increase_leaf = leaves.size() < target_leaf_cnt
		var candidates = []
		
		# 筛选逻辑
		if can_increase_leaf:
			candidates = _filter_has_space(internals)
			if candidates.is_empty(): 
				candidates = _filter_has_space(leaves)
		else:
			candidates = _filter_has_space(leaves)
		
		if candidates.is_empty():
			if current_count < target_room_cnt:
				printerr("Map generation: Space exhausted at count ", current_count)
			break
			
		# 随机挑选一个父节点
		parent_idx = candidates.pick_random()
		
		# 获取可用位置（内部已 shuffle）
		var pos_list = _get_available_positions(points[parent_idx])
		
		# 从可用位置中随机选一个
		var new_pos = pos_list.pick_random()
		
		# 添加新点和边
		var new_idx = _add_point(new_pos)
		_add_bidirectional_edge(parent_idx, new_idx)
		current_count += 1
		
		# 更新节点状态（叶子节点 vs 内部节点）
		_update_node_status(parent_idx, new_idx, leaves, internals)

# --- 核心随机探测函数 ---
func _get_available_positions(u_pos: Vector2i) -> Array[Vector2i]:
	var list : Array[Vector2i] = []
	var index_order = Array(range(4))
	index_order.shuffle() # 关键：随机化探测方向顺序
	
	for i in index_order:
		var p = u_pos + Vector2i(mx[i], my[i])
		if not point_map.has(p): 
			list.append(p)
	return list

# --- 其他原有函数保持不变 ---

func get_neighbors(u_idx: int) -> Array:
	var neighbors = []
	var u_pos = points[u_idx]
	var i = head[u_idx]
	while i != -1:
		var v_idx = edges[i].v
		var v_pos = points[v_idx]
		var diff = v_pos - u_pos 
		neighbors.append([v_idx, diff])
		i = edges[i].next
	return neighbors

func get_direction_string(u_idx: int) -> String:
	var dirs = ""
	var u_pos = points[u_idx]
	var i = head[u_idx]
	while i != -1:
		var v_pos = points[edges[i].v]
		var diff = v_pos - u_pos
		if diff == Vector2i(0, -1): dirs += "U"
		elif diff == Vector2i(0, 1): dirs += "D"
		elif diff == Vector2i(-1, 0): dirs += "L"
		elif diff == Vector2i(1, 0): dirs += "R"
		i = edges[i].next
	return dirs

func assign_room_logic_types(leaf_config: Dictionary, normal_prefix: String):
	var all_indices = range(points.size())
	var leaf_indices = []
	
	for i in all_indices:
		if i == 0: 
			room_types[i] = "start"
			continue
		if _get_conn_count(i) == 1:
			leaf_indices.append(i)
		else:
			room_types[i] = normal_prefix

	# 距离排序：通常把 Boss 放在离起点最远的地方
	leaf_indices.sort_custom(func(a, b): 
		return points[a].length_squared() < points[b].length_squared()
	)

	var current_leaf_pool = leaf_indices.duplicate()
	for type_key in leaf_config.keys():
		var count = leaf_config[type_key]
		for n in range(count):
			if current_leaf_pool.is_empty(): break
			var idx = current_leaf_pool.pop_front()
			room_types[idx] = type_key

	for idx in current_leaf_pool:
		room_types[idx] = leaf_config.keys()[0] if not leaf_config.is_empty() else normal_prefix

func _update_node_status(p_idx: int, n_idx: int, leaves: Array, internals: Array):
	if not n_idx in leaves:
		leaves.append(n_idx)
	
	var p_conn = _get_conn_count(p_idx)
	# 如果父节点连接数 > 1，它就不再是叶子节点
	if p_conn > 1:
		if p_idx in leaves:
			leaves.erase(p_idx)
		if not p_idx in internals:
			internals.append(p_idx)

func _filter_has_space(node_indices: Array) -> Array:
	var result = []
	for idx in node_indices:
		if not _get_available_positions(points[idx]).is_empty():
			result.append(idx)
	return result

func _get_conn_count(idx: int) -> int:
	var count = 0
	var curr = head[idx]
	while curr != -1:
		count += 1
		curr = edges[curr].next
	return count

func _add_bidirectional_edge(u: int, v: int):
	_add_edge(u, v)
	_add_edge(v, u)

func _add_point(pos: Vector2i) -> int:
	if point_map.has(pos): return point_map[pos]
	var idx = points.size()
	points.append(pos)
	point_map[pos] = idx
	head.append(-1)
	return idx

func _add_edge(u: int, v: int):
	var e = Edge.new()
	e.v = v
	e.next = head[u]
	edges.append(e)
	head[u] = edges.size() - 1

func iter_map(callback: Callable):
	if points.is_empty(): return
	var visited = []
	visited.resize(points.size())
	visited.fill(false)
	_dfs(0, callback, visited)

func _dfs(u: int, callback: Callable, visited: Array):
	visited[u] = true
	var i = head[u]
	while i != -1:
		var v = edges[i].v
		if not visited[v]:
			callback.call(u, v)
			_dfs(v, callback, visited)
		i = edges[i].next