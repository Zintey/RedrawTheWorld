extends Node2D
class_name MapGenerator

@export var room_container : Node2D
@export var map_config : Dictionary = {
	"room_cnt" : 15,
	"leaf_cnt" : 7,
}
@export_dir var map_prefab_dir_path : String
# @export var spacing: float = 1000.0  <-- 删除这个变量

var map_prefabs : Dictionary = {} 
var map: Map
var spawned_rooms : Dictionary = {} # 记录已生成的房间实例 { grid_pos: room_instance }

func _ready():
	_load_map_prefabs()
	# generate_new_map() # 暂时注释掉，建议手动触发或在主场景调用

func generate_new_map():
	map = Map.new().generate_map(map_config)
	if room_container:
		for child in room_container.get_children():
			child.queue_free()
	spawned_rooms.clear()
	_spawn_rooms()

# --- 核心修改：基于边界衔接的生成逻辑 ---
func _spawn_rooms():
	if not room_container or map.points.is_empty(): return
	print("--- 开始无缝生成地图 ---")
	
	# BFS 队列，存储网格坐标
	var queue : Array[Vector2i] = []
	
	# 1. 生成起点房间 (假设 index 0 是起点)
	var start_pos = map.points[0]
	var start_room = _instantiate_room(0)
	if not start_room: 
		push_error("起点房间生成失败！")
		return
		
	start_room.global_position = Vector2.ZERO # 起点放在世界中心
	spawned_rooms[start_pos] = start_room
	queue.append(start_pos)
	
	# 2. 广度优先遍历并放置
	var head = 0
	while head < queue.size():
		var current_grid_pos = queue[head]
		head += 1
		
		var current_room_inst = spawned_rooms[current_grid_pos]
		var current_idx = map.points.find(current_grid_pos)
		
		# 获取当前房间的所有邻居（需要 Map 类提供此功能）
		# 假设 map.get_neighbors(index) 返回一个数组，每个元素是 [邻居索引, 方向向量]
		# 例如: [[1, Vector2i(1,0)], [5, Vector2i(0,1)]]
		var neighbors = map.get_neighbors(current_idx) 
		
		for neighbor_info in neighbors:
			var neighbor_idx = neighbor_info[0]
			var dir_vec: Vector2i = neighbor_info[1]
			var neighbor_grid_pos = map.points[neighbor_idx]
			
			# 如果该邻居已经生成过，跳过
			if spawned_rooms.has(neighbor_grid_pos): continue
			
			# 实例化邻居房间
			var neighbor_room_inst = _instantiate_room(neighbor_idx)
			if not neighbor_room_inst: continue
			
			# --- 核心：计算无缝衔接位置 ---
			var new_position = current_room_inst.global_position
			
			match dir_vec:
				Vector2i.RIGHT: # (1, 0) 向右接
					# 新房间的左边界要对齐当前房间的右边界
					new_position.x += current_room_inst.boundary.right - neighbor_room_inst.boundary.left
				Vector2i.LEFT: # (-1, 0) 向左接
					new_position.x += current_room_inst.boundary.left - neighbor_room_inst.boundary.right
				Vector2i.DOWN: # (0, 1) 向下接
					new_position.y += current_room_inst.boundary.bottom - neighbor_room_inst.boundary.top
				Vector2i.UP: # (0, -1) 向上接
					new_position.y += current_room_inst.boundary.top - neighbor_room_inst.boundary.bottom
			
			neighbor_room_inst.global_position = new_position
			
			# 记录并加入队列
			spawned_rooms[neighbor_grid_pos] = neighbor_room_inst
			queue.append(neighbor_grid_pos)
			print("放置房间 %s 在 %s, 衔接方向 %s" % [neighbor_room_inst.name, new_position, dir_vec])

# 辅助函数：实例化单个房间并计算其边界
func _instantiate_room(index: int) -> RoomBase:
	var dirs = map.get_direction_string(index)
	var scene = _get_random_room_scene(dirs)
	if not scene:
		push_error("缺少预制体: " + _get_normalized_key(dirs))
		return null
		
	var room_inst = scene.instantiate() as RoomBase
	if not room_inst:
		push_error("预制体根节点不是 RoomBase 类型！")
		return null
		
	room_container.add_child(room_inst)
	room_inst.name = "Room_%d_%s" % [index, _get_normalized_key(dirs)]
	
	# 【重要】立即强制计算边界，以便后续位置计算使用
	room_inst.calculate_boundary()
	
	return room_inst


# --- 资源处理内部函数 ---

func _load_map_prefabs():
	var dir = DirAccess.open(map_prefab_dir_path)
	if not dir:
		push_error("路径错误: " + map_prefab_dir_path)
		return

	for file_name in dir.get_files():
		if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
			var raw_prefix = file_name.get_basename().split("_")[0]
			var key = _get_normalized_key(raw_prefix)
			
			var scene = load(map_prefab_dir_path.path_join(file_name))
			if scene:
				if not map_prefabs.has(key): map_prefabs[key] = []
				map_prefabs[key].append(scene)
				print("加载预制体: [%s] 来自文件 %s" % [key, file_name])

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


# --- 调试绘图 ---
func _draw():
	if not map: return
	
	var spacing = 50
	var drawn_edges = {}
	map.iter_map(func(u, v):
			var edge_key = [u, v]
			edge_key.sort()
			if not drawn_edges.has(edge_key):
					draw_line(Vector2(map.points[u])*spacing, Vector2(map.points[v])*spacing, Color.ORANGE, 2.0)
					drawn_edges[edge_key] = true
	)
	
	for i in range(map.points.size()):
			var color = Color.WHITE
			if i == 0: color = Color.TOMATO
			elif map.get_direction_string(i).length() == 1: color = Color.SPRING_GREEN
			draw_circle(Vector2(map.points[i]) * spacing, 20.0, color)