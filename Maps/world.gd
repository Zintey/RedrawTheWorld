extends Node2D

@onready var map_generator: MapGenerator = %MapGenerator
@onready var game_camera: Camera2D = %Camera2D 
@onready var player: Player = %Player
@onready var screen_rect: ColorRect = %ScreenRect
@onready var minimap: MiniMap = %Minimap/MapLayer

func _ready():
	var generated_map = map_generator.generate_new_map()
	minimap.map = generated_map
	
	minimap.teleport_requested.connect(_on_teleport)
	for room in map_generator.spawned_rooms.values():
		room.player_entered_room.connect(_on_room_entered)

	var start_room = map_generator.spawned_rooms.get(Vector2i.ZERO)
	if start_room:
		game_camera.transition_to_room(start_room.boundary, start_room.global_position)
		
		# ==========================================
		# 【核心修复 2】：精准寻找策划配置的锚点
		# ==========================================
		var spawn_point = start_room.find_child("PlayerSpawnPoint", true, false)
		if spawn_point:
			# 如果你放了节点，就精准生在节点位置
			player.global_position = spawn_point.global_position
		else:
			# 兜底：如果你忘了放，尽量居中，但容易坠落
			push_warning("警告：StartRoom 缺少 PlayerSpawnPoint 节点！")
			var center_x = start_room.global_position.x + (start_room.boundary.left + start_room.boundary.right) / 2.0
			var center_y = start_room.global_position.y + (start_room.boundary.top + start_room.boundary.bottom) / 2.0
			player.global_position = Vector2(center_x, center_y)
			
		minimap.update_minimap(start_room)
	
	player.on_hit.connect(func(flag : bool):
		var mat = screen_rect.material as ShaderMaterial
		mat.set_shader_parameter("is_hit", flag)
	)

func _input(event):
	if event.is_action_pressed("OpenMap"):
		_toggle_map()

func _toggle_map():
	var is_opening = minimap.current_mode == MiniMap.Mode.MINI
	minimap.toggle_map_mode(is_opening)

func _on_room_entered(room: RoomBase):
	game_camera.transition_to_room(room.boundary, room.global_position)
	minimap.update_minimap(room)

func _on_teleport(grid_pos: Vector2i):
	var target = map_generator.spawned_rooms[grid_pos]
	
	# 传送也一样找安全锚点
	var spawn_point = target.find_child("PlayerSpawnPoint", true, false)
	if spawn_point:
		player.global_position = spawn_point.global_position
	else:
		var center_x = target.global_position.x + (target.boundary.left + target.boundary.right) / 2.0
		var center_y = target.global_position.y + (target.boundary.top + target.boundary.bottom) / 2.0
		player.global_position = Vector2(center_x, center_y)
	
	player.state_machine.switch_to("teleport")
	
	_on_room_entered(target)
	minimap.toggle_map_mode(false)
