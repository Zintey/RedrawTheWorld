extends Node2D
class_name MapGenerator

@export_group("Grid Config")
@export var base_unit_tiles: Vector2i = Vector2i(40, 30)  # 每个房间格子占多少 tile（宽x高）
@export var tile_size: Vector2i = Vector2i(32, 32)        # 单个 tile 的像素尺寸

@export_group("Spawning Config")
@export var room_container: Node2D  # 生成出来的房间节点都挂在这下面

var map_prefab_dir: String = ""  # 房间预制体（.tscn）所在目录，外部赋值后才能用
var map_config: Dictionary = {"target_rooms": 15, "tolerance": 2, "min_critical_path": 5}
# map_config 说明：
#   target_rooms     目标房间数量
#   tolerance        允许上下浮动的范围
#   min_critical_path 主路径最短要几个房间，太短就重新生成

var normal_room_prefix: String = "normal"    # 文件名以这个开头的算普通房间
var leaf_room_allocation: Dictionary = {}    # 各类特殊房间要放几个，格式：{"boss": 1, "shop": 2}

var prefab_data: Dictionary = {}    # 缓存所有预制体信息，key 是房间类型（文件名前缀）
var spawned_rooms: Dictionary = {}  # 已实例化到场景里的房间，key 是 grid_pos，方便按坐标查


# 扫描 map_prefab_dir 目录，把所有合法房间预制体按类型缓存进 prefab_data
# 实例化是为了读门的位置信息，读完立刻 free，不留在场景里
func _cache_all_prefabs():
	if map_prefab_dir == "": return
	var dir = DirAccess.open(map_prefab_dir)
	if not dir:
		push_error("MapGenerator: 路径无效 " + map_prefab_dir)
		return
		
	for file in dir.get_files():
		var clean_file = file.trim_suffix(".remap")
		
		if clean_file.ends_with(".tscn") or clean_file.ends_with(".scn"):
			# 文件名第一段作为类型 key，比如 "normal_01.tscn" -> "normal"
			var type_key = clean_file.get_basename().split("_")[0].to_lower()
			
			var scene = load(map_prefab_dir.path_join(clean_file))
			if not scene:
				continue
				
			var inst = scene.instantiate()
			
			if inst is RoomBase:
				var doors = inst.get_available_doors()
				if not prefab_data.has(type_key): 
					prefab_data[type_key] = []
				prefab_data[type_key].append({
					"scene": scene,
					"size": inst.grid_size,
					"doors": doors,
					"name": clean_file
				})
			inst.free()

# 生成一张新地图并把房间实例化到场景里，返回地图数据
# 会先整理配置、补齐兜底模板，然后调 Map 类算出蓝图，最后逐个匹配预制体并摆好位置
func generate_new_map() -> Map:
	# 统一转小写，避免大小写不一致导致匹配失败
	var clean_alloc = {}
	for k in leaf_room_allocation.keys(): clean_alloc[k.to_lower()] = leaf_room_allocation[k]
	var clean_normal = normal_room_prefix.to_lower()
	
	var normal_templates = prefab_data.get(clean_normal, [])
	# 没有找到 normal 房间
	if normal_templates.is_empty():
		push_warning("文件夹中没有找到任何 normal 前缀的房间！")
		normal_templates.append({
			"size": Vector2i(1, 1),
			"doors": [
				{"l_pos": Vector2i(0,0), "dir": "U"}, {"l_pos": Vector2i(0,0), "dir": "D"},
				{"l_pos": Vector2i(0,0), "dir": "L"}, {"l_pos": Vector2i(0,0), "dir": "R"}
			],
			"name": "fallback"
		})
		
	var start_templates = prefab_data.get("start", [])
	
	# 收集特殊房间模板，找不到对应前缀的就报警告
	var special_templates = {}
	for key in clean_alloc.keys():
		if prefab_data.has(key):
			special_templates[key] = prefab_data[key]
		else:
			push_warning("警告：未找到特殊房间前缀 -> " + key)
	
	# 把所有配置打包传给 Map 类去做蓝图生成
	var final_cfg = map_config.duplicate()
	final_cfg["leaf_room_allocation"] = clean_alloc
	final_cfg["normal_room_prefix"] = clean_normal
	final_cfg["normal_templates"] = normal_templates
	final_cfg["start_templates"] = start_templates
	final_cfg["special_templates"] = special_templates 
	
	var map = Map.new().generate_map(final_cfg)
	
	# 清掉上一张地图的旧节点
	for c in room_container.get_children(): c.queue_free()
	spawned_rooms.clear()
	
	# 按蓝图逐个实例化房间，算好像素坐标摆到场景里
	for r_data in map.rooms:
		var inst = _match_and_instantiate(r_data)
		if inst:
			room_container.add_child(inst)
			var px = r_data.grid_pos.x * base_unit_tiles.x * tile_size.x
			var py = r_data.grid_pos.y * base_unit_tiles.y * tile_size.y
			inst.global_position = Vector2(px, py)
			inst.grid_pos = r_data.grid_pos
			spawned_rooms[r_data.grid_pos] = inst
			
			# 告诉房间开哪几扇门
			if inst.has_method("setup_doors_by_slots"):
				inst.setup_doors_by_slots(r_data.required_doors)
	return map

# 根据蓝图数据找一个尺寸和门位置都对得上的预制体，实例化并返回
# 找不到匹配的会报错返回 null，调用方需要判空
func _match_and_instantiate(data: Map.RoomData) -> RoomBase:
	var target_type = data.type.to_lower()
	# 找不到对应类型就降级用普通房间池
	var pool = prefab_data.get(target_type, prefab_data.get(normal_room_prefix.to_lower(), []))
	
	# 过滤出尺寸匹配、且门位都能对上的候选
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
		push_error("坐标 %s 匹配失败！" % data.grid_pos)
		return null
		
	# 有 GameManager 就用可复现的 map_rng，没有就随便选一个
	var chosen = null
	if has_node("/root/GameManager"):
		chosen = GameManager.pick_random_from_array(valid_candidates, GameManager.map_rng)
	else:
		chosen = valid_candidates.pick_random()
		
	var inst = chosen.scene.instantiate() as RoomBase
	inst.room_type = target_type
	inst.grid_size = data.grid_size
	return inst