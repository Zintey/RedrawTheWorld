# minimap.gd
extends Control
class_name MiniMap

enum Mode { MINI, FULL }
var current_mode = Mode.MINI

var map : Map
var visited_rooms : Dictionary = {}
var current_grid_pos : Vector2i = Vector2i.ZERO

# --- 平滑与交互变量 ---
var smooth_grid_pos : Vector2 = Vector2.ZERO 
var manual_offset : Vector2 = Vector2.ZERO   
var zoom_level : float = 1.0

# --- 配置参数 ---
const SPACING = 15.0
const ROOM_SIZE = 10.0
const ZOOM_SPEED = 0.1
const ZOOM_MIN = 0.5
const ZOOM_MAX = 3.0

# --- 颜色配置 ---
const COLOR_CURRENT = Color(1, 1, 1)       
const COLOR_VISITED = Color(0.5, 0.5, 0.5)  
const COLOR_NEIGHBOR = Color(0.2, 0.2, 0.2) 
const COLOR_HOVER = Color.BLUE


var hover_grid_pos

signal teleport_requested(grid_pos: Vector2i)

func _ready():
	# 初始化：当前节点（MapLayer）允许鼠标穿透
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# 修改父节点（Minimap）属性：小地图状态下彻底忽略鼠标，不挡游戏
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

	# --- 核心：修改父节点的鼠标输入属性 ---
	# 展开地图时：STOP（拦截鼠标，可以拖拽和点击）
	# 小地图时：IGNORE（忽略鼠标，点击穿透到背后的游戏）
	container.mouse_filter = Control.MOUSE_FILTER_STOP if is_full else Control.MOUSE_FILTER_IGNORE

	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if is_full:
		# 展开动画：全屏居中 (占屏幕中心 15% 到 85% 的区域)
		tween.tween_property(container, "anchor_left", 0.15, 0.4)
		tween.tween_property(container, "anchor_right", 0.85, 0.4)
		tween.tween_property(container, "anchor_top", 0.15, 0.4)
		tween.tween_property(container, "anchor_bottom", 0.85, 0.4)
		tween.tween_property(container, "offset_left", 0, 0.4)
		tween.tween_property(container, "offset_right", 0, 0.4)
		tween.tween_property(container, "offset_top", 0, 0.4)
		tween.tween_property(container, "offset_bottom", 0, 0.4)
	else:
		# 收回动画：固定在右上角
		# 将锚点定死在右上角 (1.0, 0.0)
		tween.tween_property(container, "anchor_left", 1.0, 0.4)
		tween.tween_property(container, "anchor_right", 1.0, 0.4)
		tween.tween_property(container, "anchor_top", 0.0, 0.4)
		tween.tween_property(container, "anchor_bottom", 0.0, 0.4)
		# 向左偏移 170 像素，高度设为 170 (包含 20 像素的安全边距，实际大小 150x150)
		tween.tween_property(container, "offset_left", -170, 0.4)
		tween.tween_property(container, "offset_right", -20, 0.4)
		tween.tween_property(container, "offset_top", 20, 0.4)
		tween.tween_property(container, "offset_bottom", 170, 0.4)

	tween.finished.connect(func(): queue_redraw())

func _gui_input(event: InputEvent):
	if current_mode != Mode.FULL: return

	if _get_grid_at_pos(event.position) != hover_grid_pos:
		hover_grid_pos = _get_grid_at_pos(event.position)
		queue_redraw()

	# 1. 滚轮缩放与点击判定
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_level = clamp(zoom_level + ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_level = clamp(zoom_level - ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clicked_grid = _get_grid_at_pos(event.position)
			if visited_rooms.has(clicked_grid) and clicked_grid != current_grid_pos:
				teleport_requested.emit(clicked_grid)
		
		accept_event() # 消耗事件，防止地图上的点击传给下层

	# 2. 鼠标左键拖拽（依赖 button_mask 实时判断，解决拖拽残留Bug）
	if event is InputEventMouseMotion:
		
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			manual_offset += event.relative
			queue_redraw()

# 处理点击 UI 外部的空白区域
func _unhandled_input(event: InputEvent):
	if current_mode == Mode.FULL and event is InputEventMouseButton:
		# 如果地图处于全屏状态，且你在外部屏幕按下了左键
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_map_mode(false)
			get_viewport().set_input_as_handled() # 拦截本次点击，防止玩家在关地图时突然开枪或走动

func _get_grid_at_pos(local_pos: Vector2) -> Vector2i:
	var canvas_center = size / 2.0 + manual_offset
	var scaled_spacing = SPACING * zoom_level
	var gx = round((local_pos.x - canvas_center.x) / scaled_spacing)
	var gy = round((local_pos.y - canvas_center.y) / scaled_spacing)
	return Vector2i(int(gx), int(gy))

func _draw():
	if not map: return
	
	var draw_origin = size / 2.0
	if current_mode == Mode.MINI:
		draw_origin -= smooth_grid_pos * SPACING
	else:
		draw_origin += manual_offset
		
	draw_set_transform(draw_origin, 0.0, Vector2.ONE * zoom_level)

	var visible_rooms = {} 
	for pos in visited_rooms:
		visible_rooms[pos] = true
		var idx = map.point_map.get(pos)
		for neighbor_info in map.get_neighbors(idx):
			var n_pos = map.points[neighbor_info[0]]
			if not visible_rooms.has(n_pos):
				visible_rooms[n_pos] = false

	map.iter_map(func(u, v):
		var p_u = map.points[u]
		var p_v = map.points[v]
		if visible_rooms.has(p_u) and visible_rooms.has(p_v):
			if visited_rooms.has(p_u) or visited_rooms.has(p_v):
				draw_line(Vector2(p_u) * SPACING, Vector2(p_v) * SPACING, Color.GRAY, 2.0)
	)

	for pos in visible_rooms:
		var is_visited = visible_rooms[pos]
		var color = COLOR_NEIGHBOR
		
		if pos == current_grid_pos:
			color = COLOR_CURRENT
		elif current_mode == Mode.FULL and visited_rooms.has(hover_grid_pos) and pos == hover_grid_pos:
			color = COLOR_HOVER
		elif is_visited:
			color = COLOR_VISITED
			
		var rect_pos = Vector2(pos) * SPACING - Vector2(ROOM_SIZE/2, ROOM_SIZE/2)
		draw_rect(Rect2(rect_pos, Vector2(ROOM_SIZE, ROOM_SIZE)), color)
		draw_rect(Rect2(rect_pos, Vector2(ROOM_SIZE, ROOM_SIZE)), Color(0, 0, 0, 0.6), false, 1.0)