# World.gd (主场景脚本示例)
# World.gd (主场景脚本示例)
extends Node2D

@onready var map_generator: MapGenerator = $MapGenerator
@onready var game_camera: Camera2D = $Camera2D # 确保它挂载了 GameCamera.gd
@onready var player: Player = $Player
@onready var screen_rect: ColorRect = %ScreenRect
@onready var minimap: MiniMap = %Minimap/MapLayer

# # world.gd 中的 _ready 函数 [cite: 1]
# func _ready():
# 	# 1. 生成地图并赋值给小地图
# 	var generated_map = map_generator.generate_new_map()
# 	minimap.map = generated_map
	
# 	# 2. 连接信号
# 	for room in map_generator.spawned_rooms.values():
# 		if room is RoomBase:
# 			# 原有的摄像机连接
# 			room.player_entered_room.connect(func(r): 
# 				game_camera.transition_to_room(r.boundary, r.global_position)
# 				# 新增：更新小地图状态
# 				minimap.update_minimap(r)
# 			)
			
# 	# 3. 初始化起点 [cite: 1]

	
	
func _ready():
	# [cite: 23] 初始化地图
	var generated_map = map_generator.generate_new_map()
	minimap.map = generated_map
	
	minimap.teleport_requested.connect(_on_teleport)
	for room in map_generator.spawned_rooms.values():
		room.player_entered_room.connect(_on_room_entered)

	var start_room = map_generator.spawned_rooms.get(Vector2i.ZERO)
	if start_room:
		game_camera.transition_to_room(start_room.boundary, start_room.global_position)
		player.global_position = start_room.global_position
		# 起点默认进入
		minimap.update_minimap(start_room)
	
	
	player.on_hit.connect(func(flag : bool) :
		var mat = screen_rect.material as ShaderMaterial
		mat.set_shader_parameter("is_hit", flag)
		)

func _input(event):
	if event.is_action_pressed("OpenMap"):
		_toggle_map()
		# 可以根据需要暂停游戏
		# get_tree().paused = is_opening 

func _toggle_map():
	var is_opening = minimap.current_mode == MiniMap.Mode.MINI
	minimap.toggle_map_mode(is_opening)

func _on_room_entered(room: RoomBase):
	# 摄像机过渡 
	game_camera.transition_to_room(room.boundary, room.global_position)
	# 小地图平滑更新
	minimap.update_minimap(room)

func _on_teleport(grid_pos: Vector2i):
	var target = map_generator.spawned_rooms[grid_pos]
	
	player.global_position = target.global_position
	player.state_machine.switch_to("teleport")
	
	_on_room_entered(target)
	minimap.toggle_map_mode(false)