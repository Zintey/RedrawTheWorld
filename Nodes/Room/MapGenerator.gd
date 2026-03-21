extends Node2D
class_name MapGenerator

@export_group("Grid Config")
@export var base_unit_tiles: Vector2i = Vector2i(40, 30) 
@export var tile_size: Vector2i = Vector2i(32, 32)      

@export_group("Spawning Config")
@export var room_container: Node2D
@export_dir var map_prefab_dir: String
# 【注意】属性配置变更：改为 target_rooms(基准数量) 和 tolerance(容差值)
@export var map_config: Dictionary = {"target_rooms": 15, "tolerance": 2, "min_critical_path": 5}
@export var normal_room_prefix: String = "normal"
@export var leaf_room_allocation: Dictionary = {"boss": 1, "shop": 1, "treasure": 1}

var prefab_metadata: Dictionary = {}
var spawned_rooms: Dictionary = {}   

func _ready():
	_cache_all_prefabs()

func _cache_all_prefabs():
	var dir = DirAccess.open(map_prefab_dir)
	if not dir:
		push_error("MapGenerator: 路径无效 " + map_prefab_dir)
		return
		
	for file in dir.get_files():
		if file.ends_with(".tscn") or file.ends_with(".scn"):
			var type_key = file.get_basename().split("_")[0].to_lower()
			var scene = load(map_prefab_dir.path_join(file))
			var inst = scene.instantiate()
			
			if inst is RoomBase:
				var doors = inst.get_available_doors()
				if not prefab_metadata.has(type_key): 
					prefab_metadata[type_key] = []
				prefab_metadata[type_key].append({
					"scene": scene,
					"size": inst.grid_size,
					"doors": doors,
					"name": file
				})
			inst.free()

func generate_new_map() -> Map:
	var clean_alloc = {}
	for k in leaf_room_allocation.keys(): clean_alloc[k.to_lower()] = leaf_room_allocation[k]
	var clean_normal = normal_room_prefix.to_lower()
	
	# 收集普通与起始模板
	var normal_templates = prefab_metadata.get(clean_normal, [])
	if normal_templates.is_empty():
		push_warning("警告：文件夹中没有找到任何 normal 前缀的房间！使用兜底单门模板。")
		normal_templates.append({
			"size": Vector2i(1, 1),
			"doors": [
				{"l_pos": Vector2i(0,0), "dir": "U"}, {"l_pos": Vector2i(0,0), "dir": "D"},
				{"l_pos": Vector2i(0,0), "dir": "L"}, {"l_pos": Vector2i(0,0), "dir": "R"}
			],
			"name": "fallback"
		})
		
	var start_templates = prefab_metadata.get("start", [])
	
	# ===============================================
	# 【核心新增】：收集所有特殊房间（如Boss房）的真实模板
	# ===============================================
	var special_templates = {}
	for key in clean_alloc.keys():
		if prefab_metadata.has(key):
			special_templates[key] = prefab_metadata[key]
		else:
			push_warning("警告：文件夹未找到要求的特殊房间前缀 -> " + key)
	
	var final_cfg = map_config.duplicate()
	final_cfg["leaf_room_allocation"] = clean_alloc
	final_cfg["normal_room_prefix"] = clean_normal
	final_cfg["normal_templates"] = normal_templates
	final_cfg["start_templates"] = start_templates
	final_cfg["special_templates"] = special_templates 
	
	var map = Map.new().generate_map(final_cfg)
	
	for c in room_container.get_children(): c.queue_free()
	spawned_rooms.clear()
	
	for r_data in map.rooms:
		var inst = _match_and_instantiate(r_data)
		if inst:
			room_container.add_child(inst)
			
			var px = r_data.grid_pos.x * base_unit_tiles.x * tile_size.x
			var py = r_data.grid_pos.y * base_unit_tiles.y * tile_size.y
			inst.global_position = Vector2(px, py)
			inst.grid_pos = r_data.grid_pos
			spawned_rooms[r_data.grid_pos] = inst
			
			if inst.has_method("setup_doors_by_slots"):
				inst.setup_doors_by_slots(r_data.required_doors)
	return map

func _match_and_instantiate(data: Map.RoomData) -> RoomBase:
	var target_type = data.type.to_lower()
	var pool = prefab_metadata.get(target_type, prefab_metadata.get(normal_room_prefix.to_lower(), []))
	
	var valid_candidates = []
	for meta in pool:
		if meta.size != data.grid_size: continue
		var is_ok = true
		for req in data.required_doors:
			if not meta.doors.any(func(d): return d.l_pos == req.local_pos and d.dir == req.dir):
				is_ok = false
				break
		if is_ok: valid_candidates.append(meta)
	
	if valid_candidates.is_empty():
		_print_deadlock_diag(data, pool)
		return null
		
	var chosen = valid_candidates.pick_random()
	var inst = chosen.scene.instantiate() as RoomBase
	inst.room_type = target_type
	inst.grid_size = data.grid_size
	return inst

func _print_deadlock_diag(data, pool):
	push_error("死锁警告: 坐标 %s 匹配失败！尺寸: %s, 类型: %s" % [data.grid_pos, data.grid_size, data.type])
	var req_str = ""
	for d in data.required_doors: req_str += "[%s格 开%s] " % [d.local_pos, d.dir]
	print("  -> 需求: ", req_str)
	for m in pool:
		var p_str = ""
		for d in m.doors: p_str += "[%s格 开%s] " % [d.l_pos, d.dir]
		print("     - %s (尺寸%s): %s" % [m.name, m.size, p_str])
