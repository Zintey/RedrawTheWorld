extends Node2D
class_name RoomBase

# signal player_entered(boundary: Boundary, room_global_pos: Vector2)

@export var door_scene: PackedScene
## better-terrain 面板里 platform_4 的索引（从0开始数）
@export var terrain_type: int = 3
@export var door_width_tiles: int = 4
@export var door_depth_tiles: int = 4

@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var room_area: Area2D = $RoomArea
@onready var collision_shape: CollisionShape2D = $RoomArea/CollisionShape2D

# 在 RoomBase.gd 中增加变量 [cite: 2]
var grid_pos: Vector2i  # 记录该房间在 Map 数据中的坐标

# 修改信号，增加房间实例参数
signal player_entered_room(room: RoomBase)

class Boundary:
	var left : int
	var right : int
	var top : int
	var bottom : int

var boundary : Boundary
var _pending_dirs: String = ""

func _ready() -> void:
	calculate_boundary()
	room_area.body_entered.connect(func(body):
		if body.name == "Player":
			# 发送整个房间实例，方便获取 grid_pos 和 boundary [cite: 2]
			emit_signal("player_entered_room", self) 
	)

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

	# 删所有门口格子，收集被删的坐标
	for dir in _pending_dirs:
		var cleared = _clear_door(dir, used_rect)
		all_cleared.append_array(cleared)

	# 用 better-terrain 更新受影响区域
	# update_terrain_cells 会自动连带更新邻居
	BetterTerrain.update_terrain_cells(tile_map_layer, all_cleared)

	# 放门预制体
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
	var door_local_pos = tile_map_layer.position + tile_map_layer.map_to_local(door_pos_tile)
	# 门的轴心在 (0, -64)，需要偏移 64px 补偿，让视觉中心对齐门口
	var pivot_offset := Vector2(0, -64)
	match dir:
		"L", "R":
			door_local_pos.y += tile_size.y * (door_width_tiles - 1) / 2.0
			door_inst.rotation_degrees = 0.0
			# L/R 门竖向放置，pivot 的 y 偏移直接补偿
			door_local_pos -= pivot_offset
		"U", "D":
			door_local_pos.x += tile_size.x * (door_width_tiles - 1) / 2.0
			door_inst.rotation_degrees = 90.0
			# 旋转 90 度后，原来的 y 偏移变成 x 方向
			door_local_pos.x += pivot_offset.y
	door_inst.position = door_local_pos