extends RefCounted
class_name Map

# 四个方向对应的格子偏移，U/D/L/R
const DIR_OFFSETS = {
	"U": Vector2i(0, -1), "D": Vector2i(0, 1),
	"L": Vector2i(-1, 0), "R": Vector2i(1, 0)
}
# 方向取反用
const OPPOSITE_DIR = { "U": "D", "D": "U", "L": "R", "R": "L" }

class RoomData:
	var id: int              # 在 rooms 数组里的下标
	var grid_pos: Vector2i   # 房间左上角的格子坐标
	var grid_size: Vector2i  # 房间占几格（宽x高
	var type: String = "normal"     # 房间类型，和预制体文件名前缀对应
	var depth: int = 0              # 距离起始房间的深度
	var required_doors: Array = []  # 这个房间可以开的门，格式：[{local_pos, dir}, ...]

var rooms: Array[RoomData] = []  # 所有已放置的房间
var grid_map: Dictionary = {}    # 格子坐标 -> room id 的占用表，用来做碰撞检测

# 以下几个是从 config 拆出来的，generate_map 时赋值，供内部函数共用
var normal_templates: Array = []
var start_templates: Array = []
var special_templates: Dictionary = {}
var leaf_config: Dictionary = {}

# 地图生成
# 最多试 100 次，成功就返回自身，全失败则报错
func generate_map(config: Dictionary) -> Map:
	normal_templates = config.get("normal_templates", [])
	start_templates = config.get("start_templates", [])
	special_templates = config.get("special_templates", {})
	leaf_config = config.get("leaf_room_allocation", {})
	
	var attempts = 0
	var max_attempts = 100 
	
	while attempts < max_attempts:
		if _try_generate_blueprint(config):
			print("[Debug] 蓝图生成成功！尝试次数: ", attempts + 1, " 最终房间数: ", rooms.size())
			return self
		attempts += 1
		print("[Debug] 生成尝试 %d 失败" % attempts)
		
	push_error("生成失败！。")
	return self

# 地图生成尝试
# 返回 true 表示成功，false 表示这次不满足条件，让外层重试
func _try_generate_blueprint(config: Dictionary) -> bool:
	rooms.clear()
	grid_map.clear()
	
	var target_rooms = config.get("target_rooms", 15)
	var tolerance = config.get("tolerance", 2)
	var min_critical_path = config.get("min_critical_path", 5)
	
	# 把特殊房间展开成有序列表，boss 优先排前面(最深的叶子节点给 boss)
	var special_order = []
	if leaf_config.has("boss"):
		for i in range(leaf_config["boss"]): special_order.append("boss")
	for k in leaf_config.keys():
		if k == "boss": continue
		for i in range(leaf_config[k]): special_order.append(k)
		
	var special_count = special_order.size()
	var normal_target = target_rooms - special_count
	var min_normal = max(1, normal_target - tolerance)
	var max_normal = normal_target + tolerance
	
	# 放起始房间
	var start_tmpl = _get_start_template()
	var start_room = _create_room(Vector2i.ZERO, start_tmpl.size, 0)
	start_room.type = "start" 
	
	# 把起始房间所有门都加入"待连接边"队列
	var open_edges = []
	for door in start_tmpl.doors:
		open_edges.append({
			"room_id": start_room.id,
			"grid_pos": start_room.grid_pos + door.l_pos,
			"local_pos": door.l_pos,
			"dir": door.dir
		})
		
	# 随机扩展普通房间
	var normal_rooms_generated = 1  # 把 start 算进去
	while normal_rooms_generated < max_normal and not open_edges.is_empty():
		
		# 达到最低数量后，有 20% 概率提前停手，让地图形状更随机
		if normal_rooms_generated >= min_normal and GameManager.map_rng.randf() < 0.2:
			break
			
		# 随机挑一条待连接边来扩展
		var edge_idx = GameManager.map_rng.randi() % open_edges.size()
		var edge = open_edges[edge_idx]
		open_edges.remove_at(edge_idx)
		
		var target_grid = edge.grid_pos + DIR_OFFSETS[edge.dir]
		if grid_map.has(target_grid): continue  # 格子已被占，跳过
		
		# 找能在这个位置对接的普通房间模板
		var req_dir = OPPOSITE_DIR[edge.dir]
		var valid_options = _find_valid_options(normal_templates, req_dir, target_grid)
		
		if valid_options.is_empty(): continue
		
		# 随机选一个，建房间，双向记录门连接
		var chosen = GameManager.pick_random_from_array(valid_options, GameManager.map_rng)
		var new_depth = rooms[edge.room_id].depth + 1
		var new_room = _create_room(chosen.origin, chosen.template.size, new_depth)
		
		rooms[edge.room_id].required_doors.append({"local_pos": edge.local_pos, "dir": edge.dir})
		new_room.required_doors.append({"local_pos": chosen.socket.l_pos, "dir": chosen.socket.dir})
		
		# 新房间剩余的门加入队列，继续扩展
		for door in chosen.template.doors:
			if door.l_pos == chosen.socket.l_pos and door.dir == chosen.socket.dir: continue
			open_edges.append({
				"room_id": new_room.id,
				"grid_pos": new_room.grid_pos + door.l_pos,
				"local_pos": door.l_pos,
				"dir": door.dir
			})
		normal_rooms_generated += 1
		
	# 普通房间没到下限，这次生成作废
	if normal_rooms_generated < min_normal: return false

	# 把特殊房间挂到最深的叶子节点上
	# 按深度从大到小排，优先把 boss 塞进最深处
	open_edges.sort_custom(func(a, b): return rooms[a.room_id].depth > rooms[b.room_id].depth)
	
	for sp_type in special_order:
		var placed = false
		var pool = special_templates.get(sp_type, normal_templates)
		if pool.is_empty(): pool = normal_templates
		
		# 遍历剩余边，找第一个能放下的位置
		for i in range(open_edges.size()):
			var edge = open_edges[i]
			var target_grid = edge.grid_pos + DIR_OFFSETS[edge.dir]
			if grid_map.has(target_grid): continue
			
			var req_dir = OPPOSITE_DIR[edge.dir]
			var valid_options = _find_valid_options(pool, req_dir, target_grid)
			
			if not valid_options.is_empty():
				var chosen = GameManager.pick_random_from_array(valid_options, GameManager.map_rng)
				var new_depth = rooms[edge.room_id].depth + 1
				var new_room = _create_room(chosen.origin, chosen.template.size, new_depth)
				new_room.type = sp_type
				
				rooms[edge.room_id].required_doors.append({"local_pos": edge.local_pos, "dir": edge.dir})
				new_room.required_doors.append({"local_pos": chosen.socket.l_pos, "dir": chosen.socket.dir})
				
				open_edges.remove_at(i)
				placed = true
				print("[Debug] 生成特殊房间 [%s] (尺寸%s) 在深度: %d" % [sp_type, chosen.template.size, new_depth])
				break
				
		# 某个特殊房间实在塞不进去，本次生成失败
		if not placed:
			print("[Debug] 无法生成特殊房间 [%s]，地形过于狭窄或没有门能对上" % sp_type)
			return false

	# 主路径深度不够，地图太扁，重来
	var max_depth = 0
	for r in rooms: max_depth = max(max_depth, r.depth)
	if max_depth < min_critical_path: return false
	
	return true

# 在给定的模板池里，找出所有能放在 target_grid 位置、且有一扇门朝向 req_dir 的选项
# 返回的每个元素包含模板、用于对接的门（socket）、以及房间应该放在哪个格子（origin）
func _find_valid_options(templates: Array, req_dir: String, target_grid: Vector2i) -> Array:
	var valid = []
	for tmpl in templates:
		for door in tmpl.doors:
			if door.dir == req_dir:
				var test_origin = target_grid - door.l_pos
				if _can_place_room(test_origin, tmpl.size):
					valid.append({"template": tmpl, "socket": door, "origin": test_origin})
	return valid

# 返回一个起始房间模板，有配置就随机选，没有就用四向全开的默认模板
func _get_start_template() -> Dictionary:
	if start_templates.size() > 0: 
		return GameManager.pick_random_from_array(start_templates, GameManager.map_rng)
	return {
		"size": Vector2i(1, 1),
		"doors": [
			{"l_pos": Vector2i(0, 0), "dir": "U"}, {"l_pos": Vector2i(0, 0), "dir": "D"},
			{"l_pos": Vector2i(0, 0), "dir": "L"}, {"l_pos": Vector2i(0, 0), "dir": "R"}
		]
	}

# 检查某个位置能不能放下一个指定尺寸的房间（暴力遍历每格）
func _can_place_room(origin: Vector2i, size: Vector2i) -> bool:
	for x in range(size.x):
		for y in range(size.y):
			if grid_map.has(origin + Vector2i(x, y)): return false
	return true

# 创建一个新房间数据，登记到 rooms 和 grid_map，返回引用
# id 直接用当前数组长度，所以 id == 在 rooms 里的下标
func _create_room(origin: Vector2i, size: Vector2i, depth: int) -> RoomData:
	var room = RoomData.new()
	room.id = rooms.size()
	room.grid_pos = origin
	room.grid_size = size
	room.depth = depth
	
	# 把房间覆盖的每个格子都标记上，防止别的房间重叠进来
	for x in range(size.x):
		for y in range(size.y):
			grid_map[origin + Vector2i(x, y)] = room.id
			
	rooms.append(room)
	return room