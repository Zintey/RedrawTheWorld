extends RefCounted
class_name Map

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
	_reset()
	target_room_cnt = config.get("room_cnt", 20)
	target_leaf_cnt = config.get("leaf_cnt", 5)
	target_leaf_cnt = clamp(target_leaf_cnt, 2, target_room_cnt - 1)
	
	_generate_core()
	return self

func _reset():
	edges.clear()
	points.clear()
	point_map.clear()
	head.clear()

func _generate_core():
	var p1 = Vector2i(0, 0)
	var p2 = Vector2i(0, 1)
	_add_point(p1)
	_add_point(p2)
	_add_bidirectional_edge(0, 1)
	
	var leaves = [0, 1]
	var internals = []
	var current_count = 2
	
	while current_count < target_room_cnt:
		var parent_idx : int = -1
		var can_increase_leaf = leaves.size() < target_leaf_cnt
		var candidates = []
		
		if can_increase_leaf:
			candidates = _filter_has_space(internals)
			if candidates.is_empty(): candidates = _filter_has_space(leaves)
		else:
			candidates = _filter_has_space(leaves)
		
		if candidates.is_empty():
			printerr("Map generation: Space exhausted.")
			break
			
		parent_idx = candidates.pick_random()
		var pos_list = _get_available_positions(points[parent_idx])
		var new_pos = pos_list.pick_random()
		
		var new_idx = _add_point(new_pos)
		_add_bidirectional_edge(parent_idx, new_idx)
		current_count += 1
		_update_node_status(parent_idx, new_idx, leaves, internals)

# --- 为生成器新增：获取邻居及方向向量 ---
# 返回格式: [ [neighbor_idx, Vector2i_direction], ... ]
func get_neighbors(u_idx: int) -> Array:
	var neighbors = []
	var u_pos = points[u_idx]
	var i = head[u_idx]
	while i != -1:
		var v_idx = edges[i].v
		var v_pos = points[v_idx]
		var diff = v_pos - u_pos # 得到 (0,1), (0,-1), (1,0) 或 (-1,0)
		neighbors.append([v_idx, diff])
		i = edges[i].next
	return neighbors

# --- 获取房间的开口方向字符串 ---
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

# --- 内部工具函数 ---
func _update_node_status(p_idx: int, n_idx: int, leaves: Array, internals: Array):
	leaves.append(n_idx)
	var p_conn = _get_conn_count(p_idx)
	if p_conn > 1 and p_idx in leaves:
		leaves.erase(p_idx)
		if not p_idx in internals: internals.append(p_idx)
	elif p_conn > 1 and not p_idx in internals:
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

func _get_available_positions(u_pos: Vector2i) -> Array[Vector2i]:
	var list : Array[Vector2i] = []
	for i in range(4):
		var p = u_pos + Vector2i(mx[i], my[i])
		if not point_map.has(p): list.append(p)
	return list

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