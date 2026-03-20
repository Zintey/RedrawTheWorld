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

var min_rooms: int = 10
var max_rooms: int = 15
var min_critical_path: int = 5

# 【新增】：动态形状池，不再写死
var available_shapes: Array[Vector2i] = [Vector2i(1, 1)] 

func generate_map(config: Dictionary) -> Map:
	randomize()
	min_rooms = config.get("min_rooms", 10)
	max_rooms = config.get("max_rooms", 15)
	min_critical_path = config.get("min_critical_path", 5)
	
	# 【新增】：接收来自 Generator 扫描好的动态形状池
	available_shapes = config.get("available_shapes", [Vector2i(1, 1)])
	
	var attempts = 0
	var max_attempts = 100 
	
	while attempts < max_attempts:
		if _try_generate_blueprint():
			if _assign_special_rooms(config.get("leaf_room_allocation", {}), config.get("normal_room_prefix", "normal")):
				print("地图蓝图生成成功！尝试次数: ", attempts + 1, " 总房间数: ", rooms.size(), " 支持的形状: ", available_shapes)
				return self
		attempts += 1
		
	push_error("生成失败！超过最大重试次数，请检查约束配置是否过于苛刻。")
	return self

func _try_generate_blueprint() -> bool:
	rooms.clear()
	grid_map.clear()
	
	var start_room = _create_room(Vector2i.ZERO, Vector2i(1, 1), 0)
	start_room.type = "start" 
	
	var open_edges = _get_room_perimeters(start_room)
	
	while rooms.size() < max_rooms and not open_edges.is_empty():
		var edge_idx = randi() % open_edges.size()
		var edge = open_edges[edge_idx]
		open_edges.remove_at(edge_idx)
		
		var target_grid = edge.grid_pos + DIR_OFFSETS[edge.dir]
		if grid_map.has(target_grid): continue 
		
		# 【修改】：从动态形状池里随机抽取尺寸
		var shape = available_shapes.pick_random()
		var local_align = Vector2i(randi() % shape.x, randi() % shape.y)
		var new_room_origin = target_grid - local_align
		
		if _can_place_room(new_room_origin, shape):
			var new_depth = rooms[edge.room_id].depth + 1
			var new_room = _create_room(new_room_origin, shape, new_depth)
			
			rooms[edge.room_id].required_doors.append({
				"local_pos": edge.local_pos,
				"dir": edge.dir
			})
			new_room.required_doors.append({
				"local_pos": local_align,
				"dir": OPPOSITE_DIR[edge.dir]
			})
			
			open_edges.append_array(_get_room_perimeters(new_room))
			
	if rooms.size() < min_rooms: return false
	
	var max_depth = 0
	for r in rooms: max_depth = max(max_depth, r.depth)
	if max_depth < min_critical_path: return false
	
	return true

func _can_place_room(origin: Vector2i, size: Vector2i) -> bool:
	for x in range(size.x):
		for y in range(size.y):
			if grid_map.has(origin + Vector2i(x, y)):
				return false
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

func _get_room_perimeters(room: RoomData) -> Array:
	var edges = []
	for x in range(room.grid_size.x):
		for y in range(room.grid_size.y):
			var local_p = Vector2i(x, y)
			var abs_p = room.grid_pos + local_p
			for dir in DIR_OFFSETS:
				var neighbor_abs = abs_p + DIR_OFFSETS[dir]
				if not grid_map.has(neighbor_abs): 
					edges.append({
						"room_id": room.id,
						"grid_pos": abs_p,
						"local_pos": local_p,
						"dir": dir
					})
	return edges

func _assign_special_rooms(leaf_config: Dictionary, normal_prefix: String) -> bool:
	var leaf_candidates = []
	for r in rooms:
		if r.id == 0: continue
		if r.required_doors.size() == 1: 
			leaf_candidates.append(r)
		else:
			r.type = normal_prefix
			
	leaf_candidates.sort_custom(func(a, b): return a.depth > b.depth)
	
	var current_leaf_pool = leaf_candidates.duplicate()
	for type_key in leaf_config.keys():
		var count = leaf_config[type_key]
		for n in range(count):
			if current_leaf_pool.is_empty(): break
			var r = current_leaf_pool.pop_front()
			r.type = type_key
			
	for r in current_leaf_pool:
		r.type = normal_prefix
		
	return true
