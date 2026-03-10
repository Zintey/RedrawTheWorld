extends Node2D
class_name RoomBase

signal player_entered_room(room: RoomBase)
signal combat_started
signal combat_ended

enum RoomState { UNVISITED, ACTIVE, CLEARED }

@export_group("Room Config")
@export var door_scene: PackedScene
@export var terrain_type: int = 3
@export var door_width_tiles: int = 4
@export var door_depth_tiles: int = 4
@export var room_type: String = "Normal"

@export_group("Combat Config")
@export var total_waves: int = 1
@export var wave_interval: float = 0.0

@export_group("Reward Config")
@export var reward_pool: Array[PackedScene] = []
@export var reward_chance: float = 1.0

var current_state: RoomState = RoomState.UNVISITED
var current_wave: int = 0
var instantiated_doors: Array[Node] = []
var grid_pos: Vector2i
var boundary: Boundary
var _pending_dirs: String = ""

var _is_transitioning_wave: bool = false 

@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var room_area: Area2D = $RoomArea

var enemy_container: Node2D
var spawners_root: Node2D

class Boundary:
	var left : int
	var right : int
	var top : int
	var bottom : int

func _ready() -> void:
	calculate_boundary()
	
	if has_node("Enemies"):
		enemy_container = $Enemies
	else:
		enemy_container = Node2D.new()
		enemy_container.name = "Enemies"
		add_child(enemy_container)
		
	if has_node("Spawners"):
		spawners_root = $Spawners
		
	enemy_container.child_exiting_tree.connect(_on_enemy_removed)
	
	room_area.body_entered.connect(func(body):
		if body.name == "Player":
			_on_player_entered()
			emit_signal("player_entered_room", self) 
	)

func _on_player_entered() -> void:
	if current_state != RoomState.UNVISITED:
		return
		
	if room_type in ["Start", "Shop", "Treasure"] or total_waves <= 0 or not _has_any_spawners():
		_unlock_room()
		return
		
	current_state = RoomState.ACTIVE
	_lock_room()
	emit_signal("combat_started")
	
	await get_tree().create_timer(0.5).timeout
	_start_next_wave()

func _has_any_spawners() -> bool:
	if not spawners_root:
		return false
	return spawners_root.get_child_count() > 0

func _lock_room() -> void:
	for door in instantiated_doors:
		if door.has_method("close"):
			door.close(true) # 正常播放动画和声音

func _unlock_room() -> void:
	current_state = RoomState.CLEARED
	for door in instantiated_doors:
		if door.has_method("open"):
			door.open(true) # 正常播放动画和声音
	spawn_rewards()

func _start_next_wave() -> void:
	_is_transitioning_wave = true
	current_wave += 1
	
	if current_wave > total_waves:
		emit_signal("combat_ended")
		_unlock_room()
		return
		
	if wave_interval > 0:
		await get_tree().create_timer(wave_interval).timeout
		
	if spawners_root:
		for spawner in spawners_root.get_children():
			if spawner is EnemySpawner:
				spawner.spawn_enemy(current_wave, enemy_container)
				
	await get_tree().process_frame
	_is_transitioning_wave = false
	
	_check_wave_cleared()

func _on_enemy_removed(_node: Node) -> void:
	if current_state != RoomState.ACTIVE:
		return
	_check_wave_cleared.call_deferred()

func _check_wave_cleared() -> void:
	if _is_transitioning_wave or current_state != RoomState.ACTIVE:
		return
		
	var alive_enemies = 0
	for child in enemy_container.get_children():
		if child.is_in_group("Enemy") and not child.is_queued_for_deletion():
			alive_enemies += 1
			
	if alive_enemies == 0:
		_start_next_wave()

func spawn_rewards() -> void:
	if reward_pool.is_empty():
		return
	if randf() > reward_chance:
		return
		
	var reward_scene = reward_pool.pick_random()
	if reward_scene:
		var reward_inst = reward_scene.instantiate()
		add_child(reward_inst)
		
		var center_x = (boundary.left + boundary.right) / 2.0
		var center_y = (boundary.top + boundary.bottom) / 2.0
		
		var local_center = tile_map_layer.map_to_local(tile_map_layer.local_to_map(Vector2(center_x, center_y)))
		reward_inst.position = local_center

func calculate_boundary() -> void:
	if boundary: return
	boundary = Boundary.new()
	var used := tile_map_layer.get_used_rect()
	var tile_size := tile_map_layer.tile_set.tile_size
	boundary.top    = used.position.y * tile_size.y
	boundary.bottom = used.end.y      * tile_size.y
	boundary.left   = used.position.x * tile_size.x
	boundary.right  = used.end.x      * tile_size.x

func setup_doors(connection_string: String) -> void:
	if not tile_map_layer: return
	_pending_dirs = connection_string
	await get_tree().process_frame
	_do_setup_doors()

func _do_setup_doors() -> void:
	var used_rect := tile_map_layer.get_used_rect()
	var all_cleared: Array[Vector2i] = []

	for dir in _pending_dirs:
		var cleared = _clear_door(dir, used_rect)
		all_cleared.append_array(cleared)

	BetterTerrain.update_terrain_cells(tile_map_layer, all_cleared)

	for dir in _pending_dirs:
		_place_door(dir, used_rect)

func _clear_door(dir: String, rect: Rect2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var half_w = door_width_tiles / 2
	match dir:
		"L":
			var mid_y = rect.position.y + rect.size.y / 2 - half_w
			for w in range(door_width_tiles):
				for d in range(door_depth_tiles):
					cells.append(Vector2i(rect.position.x + d, mid_y + w))
		"R":
			var mid_y = rect.position.y + rect.size.y / 2 - half_w
			for w in range(door_width_tiles):
				for d in range(door_depth_tiles):
					cells.append(Vector2i(rect.end.x - 1 - d, mid_y + w))
		"U":
			var mid_x = rect.position.x + rect.size.x / 2 - half_w
			for w in range(door_width_tiles):
				for d in range(door_depth_tiles):
					cells.append(Vector2i(mid_x + w, rect.position.y + d))
		"D":
			var mid_x = rect.position.x + rect.size.x / 2 - half_w
			for w in range(door_width_tiles):
				for d in range(door_depth_tiles):
					cells.append(Vector2i(mid_x + w, rect.end.y - 1 - d))
	for cell in cells:
		tile_map_layer.erase_cell(cell)
	return cells

func _place_door(dir: String, rect: Rect2i) -> void:
	if not door_scene: return
	var tile_size = tile_map_layer.tile_set.tile_size
	var half_w = door_width_tiles / 2
	var door_pos_tile: Vector2i
	match dir:
		"L": door_pos_tile = Vector2i(rect.position.x,     rect.position.y + rect.size.y / 2 - half_w)
		"R": door_pos_tile = Vector2i(rect.end.x - 1,      rect.position.y + rect.size.y / 2 - half_w)
		"U": door_pos_tile = Vector2i(rect.position.x + rect.size.x / 2 - half_w, rect.position.y)
		"D": door_pos_tile = Vector2i(rect.position.x + rect.size.x / 2 - half_w, rect.end.y - 1)

	var door_inst = door_scene.instantiate()
	add_child(door_inst)
	
	if door_inst.has_method("open"):
		instantiated_doors.append(door_inst)
		# --- 修改点：增加 true 参数，瞬间完成开门动画，玩家视野内不会看到门在乱动 ---
		if current_state == RoomState.UNVISITED or current_state == RoomState.CLEARED:
			door_inst.open(false, true)
			
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
