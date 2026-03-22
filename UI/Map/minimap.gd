extends Control
class_name MiniMap

enum Mode { MINI, FULL }
var current_mode = Mode.MINI

var map : Map # 必须引用新的 Map.gd 数据结构
var visited_rooms : Dictionary = {}
var current_grid_pos : Vector2i = Vector2i.ZERO

var smooth_grid_pos : Vector2 = Vector2.ZERO 
var manual_offset : Vector2 = Vector2.ZERO   
var zoom_level : float = 1.0

const SPACING = 15.0
const ROOM_SIZE = 10.0
const ZOOM_SPEED = 0.1
const ZOOM_MIN = 0.5
const ZOOM_MAX = 3.0

const COLOR_CURRENT = Color(1, 1, 1)       
const COLOR_VISITED = Color(0.5, 0.5, 0.5)  
const COLOR_NEIGHBOR = Color(0.2, 0.2, 0.2) 
const COLOR_HOVER = Color.BLUE

# 局部定义偏移量，避免找不到 Map 里的静态常数
const _DIR_OFFSETS = {
	"U": Vector2i(0, -1), "D": Vector2i(0, 1),
	"L": Vector2i(-1, 0), "R": Vector2i(1, 0)
}

var hover_grid_pos
signal teleport_requested(grid_pos: Vector2i)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	var container = get_parent()
	if container is Control:
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_minimap(room: RoomBase):
	current_grid_pos = room.grid_pos
	visited_rooms[current_grid_pos] = true
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "smooth_grid_pos", Vector2(current_grid_pos), 0.3)
	tween.parallel().tween_callback(queue_redraw)

func toggle_map_mode(is_full: bool):
	current_mode = Mode.FULL if is_full else Mode.MINI
	manual_offset = Vector2.ZERO
	zoom_level = 1.0 
	
	var container = get_parent()
	if not container is Control: return

	container.mouse_filter = Control.MOUSE_FILTER_STOP if is_full else Control.MOUSE_FILTER_IGNORE

	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if is_full:
		tween.tween_property(container, "anchor_left", 0.15, 0.4)
		tween.tween_property(container, "anchor_right", 0.85, 0.4)
		tween.tween_property(container, "anchor_top", 0.15, 0.4)
		tween.tween_property(container, "anchor_bottom", 0.85, 0.4)
		tween.tween_property(container, "offset_left", 0, 0.4)
		tween.tween_property(container, "offset_right", 0, 0.4)
		tween.tween_property(container, "offset_top", 0, 0.4)
		tween.tween_property(container, "offset_bottom", 0, 0.4)
	else:
		tween.tween_property(container, "anchor_left", 1.0, 0.4)
		tween.tween_property(container, "anchor_right", 1.0, 0.4)
		tween.tween_property(container, "anchor_top", 0.0, 0.4)
		tween.tween_property(container, "anchor_bottom", 0.0, 0.4)
		tween.tween_property(container, "offset_left", -170, 0.4)
		tween.tween_property(container, "offset_right", -20, 0.4)
		tween.tween_property(container, "offset_top", 20, 0.4)
		tween.tween_property(container, "offset_bottom", 170, 0.4)

	tween.finished.connect(func(): queue_redraw())

# 【新增】：彻底清空历史状态，供换层时调用
func clear_state():
	visited_rooms.clear()
	current_grid_pos = Vector2i.ZERO
	smooth_grid_pos = Vector2.ZERO
	manual_offset = Vector2.ZERO
	zoom_level = 1.0
	hover_grid_pos = null
	queue_redraw()

func _gui_input(event: InputEvent):
	if current_mode != Mode.FULL: return

	if _get_grid_at_pos(event.position) != hover_grid_pos:
		hover_grid_pos = _get_grid_at_pos(event.position)
		queue_redraw()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_level = clamp(zoom_level + ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_level = clamp(zoom_level - ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# 点击传送逻辑
			if hover_grid_pos != null:
				# 找出点击的格子属于哪个大房间
				var target_room_origin = null
				for room in map.rooms:
					if _is_grid_in_room(hover_grid_pos, room):
						target_room_origin = room.grid_pos
						break
				
				if target_room_origin != null and visited_rooms.has(target_room_origin) and target_room_origin != current_grid_pos:
					teleport_requested.emit(target_room_origin)
		accept_event() 

	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			manual_offset += event.relative
			queue_redraw()

func _unhandled_input(event: InputEvent):
	if current_mode == Mode.FULL and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_map_mode(false)
			get_viewport().set_input_as_handled() 

func _get_grid_at_pos(local_pos: Vector2) -> Vector2i:
	var canvas_center = size / 2.0 + manual_offset
	var scaled_spacing = SPACING * zoom_level
	var gx = round((local_pos.x - canvas_center.x) / scaled_spacing)
	var gy = round((local_pos.y - canvas_center.y) / scaled_spacing)
	return Vector2i(int(gx), int(gy))

# 辅助函数：判断某个网格坐标是否在一个房间的体积范围内
func _is_grid_in_room(grid: Vector2i, room) -> bool:
	return grid.x >= room.grid_pos.x and grid.x < room.grid_pos.x + room.grid_size.x and \
		   grid.y >= room.grid_pos.y and grid.y < room.grid_pos.y + room.grid_size.y

func _draw():
	if not map or map.rooms.is_empty(): return
	
	var draw_origin = size / 2.0
	if current_mode == Mode.MINI:
		draw_origin -= smooth_grid_pos * SPACING
	else:
		draw_origin += manual_offset
		
	draw_set_transform(draw_origin, 0.0, Vector2.ONE * zoom_level)

	# 1. 计算房间可见性
	var visible_room_ids = {}
	for room in map.rooms:
		if visited_rooms.has(room.grid_pos):
			visible_room_ids[room.id] = true
			# 把所有能通过门看到的相邻房间也标记为可见（未探索状态）
			for req_door in room.required_doors:
				var neighbor_grid = room.grid_pos + req_door.local_pos + _DIR_OFFSETS[req_door.dir]
				if map.grid_map.has(neighbor_grid):
					var neighbor_id = map.grid_map[neighbor_grid]
					if not visible_room_ids.has(neighbor_id):
						visible_room_ids[neighbor_id] = false 

	# 2. 绘制房间连线（精准连在具体的门格子上）
	for room in map.rooms:
		if not visible_room_ids.has(room.id): continue
		
		for req_door in room.required_doors:
			var my_cell = room.grid_pos + req_door.local_pos
			var neighbor_cell = my_cell + _DIR_OFFSETS[req_door.dir]
			
			if map.grid_map.has(neighbor_cell):
				var neighbor_id = map.grid_map[neighbor_cell]
				if visible_room_ids.has(neighbor_id):
					var p1 = Vector2(my_cell) * SPACING
					var p2 = Vector2(neighbor_cell) * SPACING
					draw_line(p1, p2, Color.GRAY, 2.0)

	# 3. 绘制各种尺寸的房间方块
	for room in map.rooms:
		if not visible_room_ids.has(room.id): continue
		
		var is_visited = visible_room_ids[room.id]
		var color = COLOR_NEIGHBOR
		
		if room.grid_pos == current_grid_pos:
			color = COLOR_CURRENT
		elif current_mode == Mode.FULL and hover_grid_pos != null and _is_grid_in_room(hover_grid_pos, room) and is_visited:
			color = COLOR_HOVER
		elif is_visited:
			color = COLOR_VISITED
			
		# 计算矩形的尺寸。
		# 基准点在左上角网格，每多一个网格，宽度就增加 SPACING 的距离
		var rect_pos = Vector2(room.grid_pos) * SPACING - Vector2(ROOM_SIZE/2.0, ROOM_SIZE/2.0)
		var rect_w = (room.grid_size.x - 1) * SPACING + ROOM_SIZE
		var rect_h = (room.grid_size.y - 1) * SPACING + ROOM_SIZE
		var rect_size = Vector2(rect_w, rect_h)
		
		draw_rect(Rect2(rect_pos, rect_size), color)
		draw_rect(Rect2(rect_pos, rect_size), Color(0, 0, 0, 0.6), false, 1.0)
