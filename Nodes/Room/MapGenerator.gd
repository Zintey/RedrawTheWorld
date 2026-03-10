extends Node2D
class_name MapGenerator

@export var room_container : Node2D
@export var map_config : Dictionary = {
	"room_cnt" : 15,
	"leaf_cnt" : 7,
}
@export_dir var map_prefab_dir_path : String
@export var normal_room_prefix : String = "Normal" # 普通房间的前缀
@export var leaf_room_allocation : Dictionary = {
	"Boss": 1,
	"Treasure": 1,
	"Shop": 1
}


var map_prefabs : Dictionary = {} 
var map: Map
var spawned_rooms : Dictionary = {} # 记录已生成的房间实例 { grid_pos: room_instance }

func _ready():
	_load_map_prefabs()
	# generate_new_map() # 暂时注释掉，建议手动触发或在主场景调用

func generate_new_map() -> Map:
	map = Map.new().generate_map(map_config)
	map.assign_room_logic_types(leaf_room_allocation, normal_room_prefix)
	
	if room_container:
		for child in room_container.get_children():
			child.queue_free()
	spawned_rooms.clear()
	_spawn_rooms()
	return map

# --- 核心：基于边界衔接的生成逻辑 ---
func _spawn_rooms():
	if not room_container or map.points.is_empty(): return
	print("--- 开始无缝生成地图 ---")
	
	var queue : Array[Vector2i] = []
	
	# 1. 生成起点房间
	var start_pos = map.points[0]
	# 【修复】：先实例化房间但不开门
	var start_room = _instantiate_room_no_doors(0)
	start_room.grid_pos = start_pos
	
	if not start_room: 
		push_error("起点房间生成失败！")
		return
		
	start_room.global_position = Vector2.ZERO
	spawned_rooms[start_pos] = start_room
	queue.append(start_pos)
	
	# 2. 广度优先遍历并放置
	var head = 0
	while head < queue.size():
		var current_grid_pos = queue[head]
		head += 1
		
		var current_room_inst = spawned_rooms[current_grid_pos]
		var current_idx = map.points.find(current_grid_pos)
		
		var neighbors = map.get_neighbors(current_idx) 
		
		
		for neighbor_info in neighbors:
			var neighbor_idx = neighbor_info[0]
			var dir_vec: Vector2i = neighbor_info[1]
			var neighbor_grid_pos = map.points[neighbor_idx]
			
			if spawned_rooms.has(neighbor_grid_pos): continue
			
			# 【修复】：先实例化但不开门，等位置确定后再开门
			var neighbor_room_inst = _instantiate_room_no_doors(neighbor_idx)
			neighbor_room_inst.grid_pos = neighbor_grid_pos
			if not neighbor_room_inst: continue
			
			# --- 计算无缝衔接位置 ---
			var new_position = current_room_inst.global_position
			
			match dir_vec:
				Vector2i.RIGHT: # (1, 0) 向右接
					new_position.x += current_room_inst.boundary.right - neighbor_room_inst.boundary.left
				Vector2i.LEFT: # (-1, 0) 向左接
					new_position.x += current_room_inst.boundary.left - neighbor_room_inst.boundary.right
				Vector2i.DOWN: # (0, 1) 向下接
					new_position.y += current_room_inst.boundary.bottom - neighbor_room_inst.boundary.top
				Vector2i.UP: # (0, -1) 向上接
					new_position.y += current_room_inst.boundary.top - neighbor_room_inst.boundary.bottom
			
			neighbor_room_inst.global_position = new_position
			
			spawned_rooms[neighbor_grid_pos] = neighbor_room_inst
			queue.append(neighbor_grid_pos)
			print("放置房间 %s 在 %s, 衔接方向 %s" % [neighbor_room_inst.name, new_position, dir_vec])
	
	# 【修复】：所有房间位置确定后，统一开门
	# 这样保证 setup_doors 时房间的 global_position 已经正确
	for grid_pos in spawned_rooms:
		var room_inst = spawned_rooms[grid_pos]
		var idx = map.points.find(grid_pos)
		var dirs = map.get_direction_string(idx)
		if room_inst.has_method("setup_doors"):
			room_inst.setup_doors(dirs)

# 实例化单个房间但不开门（只计算边界用于拼接）
func _instantiate_room_no_doors(index: int) -> RoomBase:
	var type_key = map.room_types.get(index, normal_room_prefix)
	
	var pool = map_prefabs.get(type_key, [])
	if pool.is_empty():
		push_error("找不到类型前缀为 %s 的预制体！" % type_key)
		pool = map_prefabs.get(normal_room_prefix, [])
	
	if pool.is_empty():
		push_error("普通房间预制体也找不到，请检查路径配置！")
		return null
	
	var scene = pool.pick_random()
	var room_inst = scene.instantiate() as RoomBase
	
	# 【修改点】：在加入节点树之前分配房间类型
	room_inst.name = "Room_%d_%s" % [index, type_key]
	room_inst.room_type = type_key 
	
	room_container.add_child(room_inst)
	room_inst.calculate_boundary() # 计算边界用于拼接，此时 position 为零点
	
	return room_inst

# --- 资源处理内部函数 ---

func _load_map_prefabs():
	var dir = DirAccess.open(map_prefab_dir_path)
	if not dir:
		push_error("路径错误: " + map_prefab_dir_path)
		return

	for file_name in dir.get_files():
		if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
			var key = file_name.get_basename().split("_")[0] 
			
			var scene = load(map_prefab_dir_path.path_join(file_name))
			if scene:
				if not map_prefabs.has(key): map_prefabs[key] = []
				map_prefabs[key].append(scene)
				print("加载预制体成功: [%s] -> %s" % [key, file_name])

func _get_random_room_scene(dirs: String) -> PackedScene:
	var key = _get_normalized_key(dirs)
	if map_prefabs.has(key):
		return map_prefabs[key].pick_random()
	return null

func _get_normalized_key(input_str: String) -> String:
	var chars = []
	for i in range(input_str.length()): chars.append(input_str[i])
	chars.sort()
	var result = ""
	for c in chars: result += c
	return result


