extends Node2D
class_name MapGenerator

@export_group("Grid Config")
@export var base_unit_tiles: Vector2i = Vector2i(40, 30) 
@export var tile_size: Vector2i = Vector2i(32, 32)      

@export_group("Spawning Config")
@export var room_container: Node2D

# 剥夺独立配置权，全部由 world.gd 动态灌入
var map_prefab_dir: String = ""
var map_config: Dictionary = {"target_rooms": 15, "tolerance": 2, "min_critical_path": 5}
var normal_room_prefix: String = "normal"
var leaf_room_allocation: Dictionary = {}

var prefab_metadata: Dictionary = {}
var spawned_rooms: Dictionary = {}   

# _ready() 中去掉了自动扫描，因为没数据。改为手动调用

func _cache_all_prefabs():
	if map_prefab_dir == "": return
	var dir = DirAccess.open(map_prefab_dir)
	if not dir:
		push_error("MapGenerator: 路径无效 " + map_prefab_dir)
		return
		
	for file in dir.get_files():
		# 【核心修复】：强行剔除打包后可能附加的 .remap 后缀
		var clean_file = file.trim_suffix(".remap")
		
		# 使用清洗干净的文件名进行判断
		if clean_file.ends_with(".tscn") or clean_file.ends_with(".scn"):
			var type_key = clean_file.get_basename().split("_")[0].to_lower()
			
			# 【注意】：传递给 load() 的必须也是清洗后的路径
			# Godot 底层如果发现处于 EXE 环境，会自动把 .tscn 映射回真正的资源
			var scene = load(map_prefab_dir.path_join(clean_file))
			if not scene:
				continue
				
			var inst = scene.instantiate()
			
			if inst is RoomBase:
				var doors = inst.get_available_doors()
				if not prefab_metadata.has(type_key): 
					prefab_metadata[type_key] = []
				prefab_metadata[type_key].append({
					"scene": scene,
					"size": inst.grid_size,
					"doors": doors,
					"name": clean_file
				})
			inst.free()

func generate_new_map() -> Map:
	var clean_alloc = {}
	for k in leaf_room_allocation.keys(): clean_alloc[k.to_lower()] = leaf_room_allocation[k]
	var clean_normal = normal_room_prefix.to_lower()
	
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
	
	var special_templates = {}
	for key in clean_alloc.keys():
		if prefab_metadata.has(key):
			special_templates[key] = prefab_metadata[key]
		else:
			push_warning("警告：未找到特殊房间前缀 -> " + key)
	
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
		push_error("死锁警告: 坐标 %s 匹配失败！" % data.grid_pos)
		return null
		
	# 【强制接入】：使用 GameManager.map_rng 抽取物理预制体外观！
	var chosen = null
	if has_node("/root/GameManager"):
		chosen = GameManager.pick_random_from_array(valid_candidates, GameManager.map_rng)
	else:
		# 纯后备防崩溃
		chosen = valid_candidates.pick_random()
		
	var inst = chosen.scene.instantiate() as RoomBase
	inst.room_type = target_type
	inst.grid_size = data.grid_size
	return inst