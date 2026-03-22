extends Node2D

@onready var map_generator: MapGenerator = %MapGenerator
@onready var game_camera: Camera2D = %Camera2D 
@onready var player: Player = %Player
@onready var screen_rect: ColorRect = %ScreenRect
@onready var minimap: MiniMap = %Minimap/MapLayer

func _ready():
	EventBus.execute_map_rebuild.connect(_on_execute_map_rebuild)
	EventBus.ready_to_change_scene.connect(_on_ready_to_change_scene)
	
	minimap.teleport_requested.connect(_on_teleport)
	player.on_hit.connect(func(flag : bool):
		var mat = screen_rect.material as ShaderMaterial
		mat.set_shader_parameter("is_hit", flag)
	)

	# 【核心】：兼容 F5 直接启动和主菜单启动
	if GameManager.current_level_data == null and GameManager.debug_start_level != null:
		# F5启动：没数据，激活大管家的调试启动器
		GameManager.start_new_run(GameManager.debug_seed, GameManager.debug_start_level)
		# 强制呼叫开局过渡 UI
		EventBus.level_transition_started.emit(true)
	elif GameManager.current_level_data != null:
		# 正常从主菜单带着数据进来的。说明此时主菜单已经发过信号拉好黑屏了，直接建图
		_generate_current_level()

# UI 黑屏拉好后（开局模式），会发这个信号。world 收到后建图
func _on_ready_to_change_scene():
	# 确保是直接运行world导致的开局，才在这里响应
	if get_tree().current_scene == self or get_tree().current_scene.name == "World":
		_generate_current_level()

func _generate_current_level():
	var level_data = GameManager.current_level_data
	if not level_data:
		push_error("world: 找不到 GameManager 中的 LevelData！")
		return

	map_generator.map_prefab_dir = level_data.map_prefab_dir
	map_generator.map_config["target_rooms"] = level_data.target_rooms
	map_generator.map_config["tolerance"] = level_data.tolerance
	map_generator.leaf_room_allocation = level_data.leaf_room_allocation
	
	map_generator.prefab_metadata.clear()
	map_generator._cache_all_prefabs()

	var generated_map = map_generator.generate_new_map()
	minimap.map = generated_map
	
	for room in map_generator.spawned_rooms.values():
		if not room.player_entered_room.is_connected(_on_room_entered):
			room.player_entered_room.connect(_on_room_entered)

	var start_room = map_generator.spawned_rooms.get(Vector2i.ZERO)
	if start_room:
		var spawn_point = start_room.find_child("PlayerSpawnPoint", true, false)
		if spawn_point:
			player.global_position = spawn_point.global_position
		else:
			var center_x = start_room.global_position.x + (start_room.boundary.left + start_room.boundary.right) / 2.0
			var center_y = start_room.global_position.y + (start_room.boundary.top + start_room.boundary.bottom) / 2.0
			player.global_position = Vector2(center_x, center_y)
			
		minimap.update_minimap(start_room)
		
	# 延迟一帧，确保地图就绪，通知UI开灯
	call_deferred("_notify_rebuild_finished")

func _notify_rebuild_finished():
	EventBus.map_rebuild_finished.emit()

# 游戏中途过场指令
func _on_execute_map_rebuild():
	player.state_machine.switch_to("teleport")
	
	if game_camera.has_method("_camera_area_stack"):
		game_camera._camera_area_stack.clear()
		if game_camera.has_method("_apply_top_camera_area"):
			game_camera._apply_top_camera_area()
	
	# 【修复】：清空小地图的历史状态
	minimap.clear_state()
	
	_generate_current_level()

# === 以下保持原有交互不变 ===
func _input(event):
	if event.is_action_pressed("OpenMap"):
		_toggle_map()

func _toggle_map():
	var is_opening = minimap.current_mode == MiniMap.Mode.MINI
	minimap.toggle_map_mode(is_opening)

func _on_room_entered(room: RoomBase):
	minimap.update_minimap(room)

func _on_teleport(grid_pos: Vector2i):
	var target = map_generator.spawned_rooms[grid_pos]
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