extends Node2D
class_name RoomBase

# 定义信号，当玩家进入房间时发出，传递房间的边界和全局位置信息
signal player_entered(boundary: Boundary, room_global_pos: Vector2)

@onready var tile_map_layer: TileMapLayer = %TileMapLayer
# 确保你的预制体里有这些节点
@onready var room_area: Area2D = $RoomArea 
@onready var collision_shape: CollisionShape2D = $RoomArea/CollisionShape2D

class Boundary:
	var left : int
	var right : int
	var top : int
	var bottom : int

var boundary : Boundary

func _ready() -> void:
	# 1. 确保边界已计算
	calculate_boundary()
	
	# 2. 根据边界设置碰撞区域
	_setup_collision_area()
	
	# 3. 连接信号监听玩家进入
	# 假设你的玩家节点名字叫 "Player"，或者你可以用 group 来判断
	room_area.body_entered.connect(func(body):
		if body.name == "Player":
			emit_signal("player_entered", boundary, global_position)
			print("玩家进入房间: ", name)
		else:
			print("jin ru fangjian")
	)

# --- 新增：公开的边界计算函数 ---
# 这个函数现在可以在 _ready 之前被外部调用
func calculate_boundary() -> void:
	if boundary: return # 避免重复计算

	boundary = Boundary.new()
	var used : Rect2i = tile_map_layer.get_used_rect()
	var tile_size := tile_map_layer.tile_set.tile_size

	# 计算相对于TileMapLayer原点的像素坐标
	boundary.top = (used.position.y) * tile_size.y
	boundary.bottom = (used.end.y) * tile_size.y
	boundary.left = (used.position.x) * tile_size.x
	boundary.right = (used.end.x) * tile_size.x
	
	# 注意：这里计算的是 TileMap 内容相对于其自身原点的边界。
	# 只要你的 TileMapLayer 节点相对于 RoomBase根节点没有位移，这个就是准的。

# --- 新增：设置碰撞区域 ---
func _setup_collision_area():
	return
	var shape = RectangleShape2D.new()
	var width = boundary.right - boundary.left
	var height = boundary.bottom - boundary.top
	shape.size = Vector2(width, height)
	collision_shape.shape = shape
	
	# 计算中心点偏移量
	var center_x = boundary.left + width / 2.0
	var center_y = boundary.top + height / 2.0
	collision_shape.position = Vector2(center_x, center_y)

# (可选) 调试绘图，查看计算出的边界和碰撞区是否一致
func _draw():
	if not boundary: return
	draw_rect(Rect2(boundary.left, boundary.top, boundary.right-boundary.left, boundary.bottom-boundary.top), Color.YELLOW, false, 2.0)
