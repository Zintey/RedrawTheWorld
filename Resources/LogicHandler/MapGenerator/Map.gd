extends RefCounted
class_name Map

const DIR_OFFSETS = {
	"U": Vector2i(0, -1), "D": Vector2i(0, 1),
	"L": Vector2i(-1, 0), "R": Vector2i(1, 0)
}
const OPPOSITE_DIR = { "U": "D", "D": "U", "L": "R", "R": "L" }

class RoomData:
	var id: int
	var grid_pos: Vector2i       
	var grid_size: Vector2i      
	var type: String = "normal"
	var depth: int = 0           
	var required_doors: Array = [] 

var rooms: Array[RoomData] = []
var grid_map: Dictionary = {} 

var normal_templates: Array = []
var start_templates: Array = []
var special_templates: Dictionary = {}
var leaf_config: Dictionary = {}

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

func _try_generate_blueprint(config: Dictionary) -> bool:
	rooms.clear()
	grid_map.clear()
	
	var target_rooms = config.get("target_rooms", 15)
	var tolerance = config.get("tolerance", 2)
	var min_critical_path = config.get("min_critical_path", 5)
	
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
	
	# 放置 Start 房间
	var start_tmpl = _get_start_template()
	var start_room = _create_room(Vector2i.ZERO, start_tmpl.size, 0)
	start_room.type = "start" 
	
	var open_edges = []
	for door in start_tmpl.doors:
		open_edges.append({
			"room_id": start_room.id,
			"grid_pos": start_room.grid_pos + door.l_pos,
			"local_pos": door.l_pos,
			"dir": door.dir
		})
		
	# ==========================================
	# 普通房间 
	# ==========================================
	var normal_rooms_generated = 1 
	while normal_rooms_generated < max_normal and not open_edges.is_empty():
		
		if normal_rooms_generated >= min_normal and GameManager.map_rng.randf() < 0.2:
			break
			
		
		var edge_idx = GameManager.map_rng.randi() % open_edges.size()
		var edge = open_edges[edge_idx]
		open_edges.remove_at(edge_idx)
		
		var target_grid = edge.grid_pos + DIR_OFFSETS[edge.dir]
		if grid_map.has(target_grid): continue 
		
		var req_dir = OPPOSITE_DIR[edge.dir]
		var valid_options = _find_valid_options(normal_templates, req_dir, target_grid)
		
		if valid_options.is_empty(): continue
			
		
		var chosen = GameManager.pick_random_from_array(valid_options, GameManager.map_rng)
		var new_depth = rooms[edge.room_id].depth + 1
		var new_room = _create_room(chosen.origin, chosen.template.size, new_depth)
		
		rooms[edge.room_id].required_doors.append({"local_pos": edge.local_pos, "dir": edge.dir})
		new_room.required_doors.append({"local_pos": chosen.socket.l_pos, "dir": chosen.socket.dir})
		
		for door in chosen.template.doors:
			if door.l_pos == chosen.socket.l_pos and door.dir == chosen.socket.dir: continue
			open_edges.append({
				"room_id": new_room.id,
				"grid_pos": new_room.grid_pos + door.l_pos,
				"local_pos": door.l_pos,
				"dir": door.dir
			})
		normal_rooms_generated += 1
		
	if normal_rooms_generated < min_normal: return false

	# ==========================================
	# 特殊房间
	# ==========================================
	open_edges.sort_custom(func(a, b): return rooms[a.room_id].depth > rooms[b.room_id].depth)
	
	for sp_type in special_order:
		var placed = false
		var pool = special_templates.get(sp_type, normal_templates)
		if pool.is_empty(): pool = normal_templates
		
		for i in range(open_edges.size()):
			var edge = open_edges[i]
			var target_grid = edge.grid_pos + DIR_OFFSETS[edge.dir]
			if grid_map.has(target_grid): continue
			
			var req_dir = OPPOSITE_DIR[edge.dir]
			var valid_options = _find_valid_options(pool, req_dir, target_grid)
			
			if not valid_options.is_empty():
				# 【修改】：使用带 map_rng 的 pick_random_from_array
				var chosen = GameManager.pick_random_from_array(valid_options, GameManager.map_rng)
				var new_depth = rooms[edge.room_id].depth + 1
				var new_room = _create_room(chosen.origin, chosen.template.size, new_depth)
				new_room.type = sp_type
				
				rooms[edge.room_id].required_doors.append({"local_pos": edge.local_pos, "dir": edge.dir})
				new_room.required_doors.append({"local_pos": chosen.socket.l_pos, "dir": chosen.socket.dir})
				
				open_edges.remove_at(i)
				placed = true
				print("[Debug] 成功接驳特殊房间 [%s] (尺寸%s) 在深度: %d" % [sp_type, chosen.template.size, new_depth])
				break
				
		if not placed:
			print("[Debug] 无法接驳特殊房间 [%s]，地形过于狭窄或没有门能对上" % sp_type)
			return false

	var max_depth = 0
	for r in rooms: max_depth = max(max_depth, r.depth)
	if max_depth < min_critical_path: return false
	
	return true

func _find_valid_options(templates: Array, req_dir: String, target_grid: Vector2i) -> Array:
	var valid = []
	for tmpl in templates:
		for door in tmpl.doors:
			if door.dir == req_dir:
				var test_origin = target_grid - door.l_pos
				if _can_place_room(test_origin, tmpl.size):
					valid.append({"template": tmpl, "socket": door, "origin": test_origin})
	return valid

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

func _can_place_room(origin: Vector2i, size: Vector2i) -> bool:
	for x in range(size.x):
		for y in range(size.y):
			if grid_map.has(origin + Vector2i(x, y)): return false
	return true

func _create_room(origin: Vector2i, size: Vector2i, depth: int) -> RoomData:
	var room = RoomData.new()
	room.id = rooms.size()
	room.grid_pos = origin
	room.grid_size = size
	room.depth = depth
	
	for x in range(size.x):
		for y in range(size.y):
			grid_map[origin + Vector2i(x, y)] = room.id
			
	rooms.append(room)
	return room
