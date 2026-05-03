@tool
extends Node2D
class_name RoomBase



signal player_entered_room(room: RoomBase)
signal combat_started
signal combat_ended

enum RoomState { UNVISITED, ACTIVE, CLEARED }

# 【新增】：过场动画配置
@export_group("Cutscene Config")
@export var intro_video: VideoStream
var _has_played_cutscene: bool = false

@export_group("Grid Config")
@export var grid_size: Vector2i = Vector2i(1, 1):
	set(v):
		grid_size = v
		notify_property_list_changed()
		_refresh_gizmo()

@export var base_unit_tiles: Vector2i = Vector2i(40, 30):
	set(v):
		base_unit_tiles = v
		_refresh_gizmo()

@export var tile_size: Vector2i = Vector2i(32, 32):
	set(v):
		tile_size = v
		_refresh_gizmo()

@export var door_scene: PackedScene
@export var door_width_tiles: int = 4:
	set(v):
		door_width_tiles = v
		_refresh_gizmo()
		
@export var door_depth_tiles: int = 2
var room_type: String = "Normal"

@export_group("Combat Config")
@export var total_waves: int = 1
@export var wave_interval: float = 0.0

@export_group("Reward Config")
@export var drop_configs: Array[DropConfig] = []
@export var drop_spawn_point: Node2D

@export_group("DoorConfig")

var current_state: RoomState = RoomState.UNVISITED
var current_wave: int = 0
var instantiated_doors: Array[Node] = []
var grid_pos: Vector2i
var boundary = {"left": 0, "right": 0, "top": 0, "bottom": 0}

var alive_enemies_count: int = 0
var enemies_spawning_count: int = 0
var is_waiting_for_next_wave: bool = false

var door_states: Dictionary = {}
var editor_gizmo: Node2D

@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var room_area: Area2D = $RoomArea

var enemy_container: Node2D
var spawners_root: Node2D



func _enter_tree():
	if Engine.is_editor_hint():
		if not editor_gizmo:
			editor_gizmo = Node2D.new()
			editor_gizmo.z_index = 100 
			editor_gizmo.draw.connect(_on_gizmo_draw)
			add_child(editor_gizmo)

func _refresh_gizmo():
	if editor_gizmo and Engine.is_editor_hint():
		editor_gizmo.queue_redraw()

func _get_property_list() -> Array:
	var props = []
	var perimeter = _calculate_perimeter()
	for p in perimeter:
		var prop_name = "Door Constraints/Grid[%d,%d]_%s" % [p.pos.x, p.pos.y, p.dir]
		props.append({
			"name": prop_name,
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return props

func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("Door Constraints/"):
		door_states[property] = value
		_refresh_gizmo()
		return true
	return false

func _get(property: StringName) -> Variant:
	if property.begins_with("Door Constraints/"):
		return door_states.get(property, true)
	return null

func _calculate_perimeter() -> Array:
	var edges = []
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if y == 0: edges.append({"pos": Vector2i(x, y), "dir": "U"})
			if y == grid_size.y - 1: edges.append({"pos": Vector2i(x, y), "dir": "D"})
			if x == 0: edges.append({"pos": Vector2i(x, y), "dir": "L"})
			if x == grid_size.x - 1: edges.append({"pos": Vector2i(x, y), "dir": "R"})
	return edges

func get_available_doors() -> Array:
	var available = []
	var perimeter = _calculate_perimeter()
	for p in perimeter:
		var prop_name = "Door Constraints/Grid[%d,%d]_%s" % [p.pos.x, p.pos.y, p.dir]
		if door_states.get(prop_name, true):
			available.append({"l_pos": p.pos, "dir": p.dir})
	return available

func _on_gizmo_draw():
	if not Engine.is_editor_hint(): return
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var rx = x * base_unit_tiles.x * tile_size.x
			var ry = y * base_unit_tiles.y * tile_size.y
			var rw = base_unit_tiles.x * tile_size.x
			var rh = base_unit_tiles.y * tile_size.y
			editor_gizmo.draw_rect(Rect2(rx, ry, rw, rh), Color(1, 1, 1, 0.15), false, 4.0)
			
	var doors = get_available_doors()
	for d in doors:
		var start_x = d.l_pos.x * base_unit_tiles.x * tile_size.x
		var start_y = d.l_pos.y * base_unit_tiles.y * tile_size.y
		var unit_w = base_unit_tiles.x * tile_size.x
		var unit_h = base_unit_tiles.y * tile_size.y
		var door_px_w = door_width_tiles * tile_size.x
		
		var rect = Rect2()
		var thickness = 40.0 
		
		match d.dir:
			"U":
				var mid_x = start_x + unit_w / 2.0
				rect = Rect2(mid_x - door_px_w/2.0, start_y, door_px_w, thickness)
			"D":
				var mid_x = start_x + unit_w / 2.0
				rect = Rect2(mid_x - door_px_w/2.0, start_y + unit_h - thickness, door_px_w, thickness)
			"L":
				var mid_y = start_y + unit_h / 2.0
				rect = Rect2(start_x, mid_y - door_px_w/2.0, thickness, door_px_w)
			"R":
				var mid_y = start_y + unit_h / 2.0
				rect = Rect2(start_x + unit_w - thickness, mid_y - door_px_w/2.0, thickness, door_px_w)
				
		editor_gizmo.draw_rect(rect, Color(0.2, 0.9, 0.2, 0.6))


# 波次战斗、掉落与开门逻辑
func _ready() -> void:
	if Engine.is_editor_hint(): return
	calculate_boundary()
	
	if has_node("Enemies"):
		enemy_container = $Enemies
	else:
		enemy_container = Node2D.new()
		enemy_container.name = "Enemies"
		add_child(enemy_container)
		
	if has_node("Spawners"):
		spawners_root = $Spawners
		for spawner in spawners_root.get_children():
			if spawner.has_signal("spawn_started"):
				spawner.spawn_started.connect(_on_spawner_spawn_started)
				spawner.enemy_spawned.connect(_on_spawner_enemy_spawned)
		
	if room_area:
		room_area.body_entered.connect(func(body):
			if body.name == "Player":
				_on_player_entered()
				emit_signal("player_entered_room", self) 
		)

func calculate_boundary() -> void:
	if not tile_map_layer: return
	var used := tile_map_layer.get_used_rect()
	var ts := tile_map_layer.tile_set.tile_size
	boundary.left   = used.position.x * ts.x
	boundary.right  = used.end.x      * ts.x
	boundary.top    = used.position.y * ts.y
	boundary.bottom = used.end.y      * ts.y

func setup_doors_by_slots(required_doors: Array) -> void:
	if Engine.is_editor_hint(): return
	if not tile_map_layer: return
	await get_tree().process_frame
	
	var all_cleared: Array[Vector2i] = []
	var unit_tiles = base_unit_tiles
	
	for req in required_doors:
		var start_x = req.local_pos.x * unit_tiles.x
		var start_y = req.local_pos.y * unit_tiles.y
		var cells: Array[Vector2i] = []
		var door_pos_tile: Vector2i
		
		match req.dir:
			"U":
				door_pos_tile = Vector2i(start_x + unit_tiles.x / 2 - door_width_tiles / 2, start_y)
				for w in range(door_width_tiles):
					for d in range(door_depth_tiles): cells.append(Vector2i(door_pos_tile.x + w, start_y + d))
			"D":
				door_pos_tile = Vector2i(start_x + unit_tiles.x / 2 - door_width_tiles / 2, start_y + unit_tiles.y - 1)
				for w in range(door_width_tiles):
					for d in range(door_depth_tiles): cells.append(Vector2i(door_pos_tile.x + w, start_y + unit_tiles.y - 1 - d))
			"L":
				door_pos_tile = Vector2i(start_x, start_y + unit_tiles.y / 2 - door_width_tiles / 2)
				for w in range(door_width_tiles):
					for d in range(door_depth_tiles): cells.append(Vector2i(start_x + d, door_pos_tile.y + w))
			"R":
				door_pos_tile = Vector2i(start_x + unit_tiles.x - 1, start_y + unit_tiles.y / 2 - door_width_tiles / 2)
				for w in range(door_width_tiles):
					for d in range(door_depth_tiles): cells.append(Vector2i(start_x + unit_tiles.x - 1 - d, door_pos_tile.y + w))
					
		for cell in cells:
			tile_map_layer.erase_cell(cell)
		all_cleared.append_array(cells)
		
		_place_door_instance(door_pos_tile, req.dir)

	var cells_to_update: Array[Vector2i] = []
	for cell in all_cleared:
		cells_to_update.append(cell)
		cells_to_update.append(cell + Vector2i(1, 0))  
		cells_to_update.append(cell + Vector2i(-1, 0)) 
		cells_to_update.append(cell + Vector2i(0, 1))  
		cells_to_update.append(cell + Vector2i(0, -1)) 
		
	if has_node("/root/BetterTerrain"):
		BetterTerrain.update_terrain_cells(tile_map_layer, cells_to_update)

func _place_door_instance(door_pos_tile: Vector2i, dir: String) -> void:
	if not door_scene: return
	var door_inst = door_scene.instantiate()
	add_child(door_inst)
	
	var door_local_pos = tile_map_layer.position + tile_map_layer.map_to_local(door_pos_tile)
	var pivot_offset := Vector2(0, -64) 
	
	match dir:
		"L", "R":
			door_local_pos.y += tile_size.y * (door_width_tiles - 1) / 2.0
			door_inst.rotation_degrees = 0.0
			door_local_pos -= pivot_offset
		"U", "D":
			door_local_pos.x += tile_size.x * (door_width_tiles - 1) / 2.0
			door_inst.rotation_degrees = 90.0
			door_local_pos.x += pivot_offset.y
			
	door_inst.position = door_local_pos
	
	if door_inst.has_method("open"):
		instantiated_doors.append(door_inst)
		if current_state == RoomState.UNVISITED or current_state == RoomState.CLEARED:
			door_inst.call_deferred("open", false, true)


func _on_player_entered() -> void:
	if current_state != RoomState.UNVISITED: return

	if intro_video and not _has_played_cutscene:
		_has_played_cutscene = true
		EventBus.cutscene_started.emit(intro_video)
		await EventBus.cutscene_finished 

	if room_type.to_lower() in ["start", "shop", "treasure"] or total_waves <= 0 or not _has_any_spawners():
		_unlock_room()
		return
		
	current_state = RoomState.ACTIVE
	_lock_room()
	emit_signal("combat_started")
	
	await get_tree().create_timer(0.5).timeout
	_start_next_wave()

func _has_any_spawners() -> bool:
	if not spawners_root: return false
	return spawners_root.get_child_count() > 0

func _lock_room() -> void:
	AudioManager.play_bgm(GameManager.current_level_data.attack_bgm)

	for door in instantiated_doors:
		if door.has_method("close"): door.close(true) 

func _unlock_room() -> void:
	match room_type.to_lower():
		"shop": AudioManager.play_bgm(GameManager.current_level_data.shop_bgm)
		_: AudioManager.play_bgm(GameManager.current_level_data.idle_bgm)

	current_state = RoomState.CLEARED
	for door in instantiated_doors:
		if door.has_method("open"): door.open(true) 
	spawn_rewards()

func _start_next_wave() -> void:
	if current_wave >= total_waves:
		emit_signal("combat_ended")
		_unlock_room()
		return
		
	is_waiting_for_next_wave = true
	if current_wave > 0 and wave_interval > 0:
		await get_tree().create_timer(wave_interval).timeout
		
	current_wave += 1
	is_waiting_for_next_wave = false
	
	if spawners_root:
		for spawner in spawners_root.get_children():
			if spawner.has_method("spawn_enemy"):
				spawner.spawn_enemy(current_wave, enemy_container)
				
	await get_tree().process_frame
	_check_wave_cleared()

func _on_spawner_spawn_started() -> void:
	enemies_spawning_count += 1

func _on_spawner_enemy_spawned(enemy: Node) -> void:
	enemies_spawning_count -= 1
	alive_enemies_count += 1
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy) -> void:
	alive_enemies_count -= 1
	_check_wave_cleared()

func _check_wave_cleared() -> void:
	if current_state != RoomState.ACTIVE: return
	if is_waiting_for_next_wave or enemies_spawning_count > 0 or alive_enemies_count > 0: return
	_start_next_wave()

func spawn_rewards() -> void:
	if drop_configs.is_empty(): return
	
	for config in drop_configs:
		if not config or not config.item_scene:
			continue
			
		if GameManager.drop_rng.randf() <= config.drop_chance:
			var reward_inst = config.item_scene.instantiate()
			add_child(reward_inst)

			var spawn_pos: Vector2
			if drop_spawn_point:
				spawn_pos = to_local(drop_spawn_point.global_position)
			else:
				var center_x = (boundary.left + boundary.right) / 2.0
				var center_y = (boundary.top + boundary.bottom) / 2.0
				spawn_pos = tile_map_layer.map_to_local(tile_map_layer.local_to_map(Vector2(center_x, center_y)))
				
			reward_inst.position = spawn_pos
			if reward_inst is RigidBody2D:
				var random_angle = GameManager.drop_rng.randf_range(-PI * 0.75, -PI * 0.25)
				var throw_force = GameManager.drop_rng.randf_range(400.0, 600.0) 
				var impulse = Vector2(cos(random_angle), sin(random_angle)) * throw_force
				reward_inst.apply_central_impulse(impulse)