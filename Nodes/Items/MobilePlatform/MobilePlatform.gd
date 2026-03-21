@tool
class_name MobilePlatform
extends AnimatableBody2D

# --- 枚举定义 ---
enum MoveMode { LINEAR, PATH }
enum ActivationMode { AUTO, ON_STEP }

# --- 核心配置变量 ---
@export var move_mode: MoveMode = MoveMode.LINEAR:
	set(value):
		move_mode = value
		notify_property_list_changed() # 切换模式时刷新面板
		queue_redraw() # 切换模式时刷新编辑器绘图

@export var activation_mode: ActivationMode = ActivationMode.AUTO:
	set(value):
		activation_mode = value
		notify_property_list_changed()

@export var move_speed: float = 100.0
@export var pause_duration: float = 1.5

# --- LINEAR (直线) 模式特有变量 ---
@export var move_direction: Vector2 = Vector2.RIGHT:
	set(value):
		move_direction = value
		queue_redraw() # 改变方向时，实时更新绘图

@export var cast_distance: float = 5.0: # 探路距离 (代替射线长度)
	set(value):
		cast_distance = value
		queue_redraw() # 改变距离时，实时更新绘图

@export_flags_2d_physics var terrain_mask: int = 32 # 地形层：默认勾选第 6 层

# --- PATH (样条线) 模式特有变量 ---
@export_node_path("Path2D") var path_node: NodePath
@export_range(0.0, 1.0) var start_progress_ratio: float = 0.0

# --- 节点引用 ---
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_detector: Area2D = $PlayerDetector
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# --- 内部状态变量 ---
var is_active: bool = false
var pause_timer: float = 0.0
var current_path_sign: int = 1 # 样条线移动方向 (1 为正向，-1 为反向)
var path_follow: PathFollow2D

# ==========================================
# 工具脚本：动态控制属性面板显示
# ==========================================
func _validate_property(property: Dictionary) -> void:
	if property.name in ["move_direction", "cast_distance", "terrain_mask"]:
		if move_mode != MoveMode.LINEAR:
			property.usage = PROPERTY_USAGE_NO_EDITOR # 隐藏直线模式的变量
			
	elif property.name in ["path_node", "start_progress_ratio"]:
		if move_mode != MoveMode.PATH:
			property.usage = PROPERTY_USAGE_NO_EDITOR # 隐藏样条线模式的变量

# ==========================================
# 初始化
# ==========================================
func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	# 启动模式配置
	if activation_mode == ActivationMode.AUTO:
		is_active = true
	else:
		if player_detector:
			# 【修改】：同时连接“进入”和“离开”信号
			player_detector.body_entered.connect(_on_player_detector_body_entered)
			player_detector.body_exited.connect(_on_player_detector_body_exited)
		else:
			push_warning("MobilePlatform: 配置为踩踏启动，但找不到 PlayerDetector 节点！")

	# 样条线模式初始化
	if move_mode == MoveMode.PATH:
		_setup_path_mode()

	_play_anim("stop")

# ==========================================
# 物理帧循环与核心移动逻辑
# ==========================================
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not is_active:
		return

	if pause_timer > 0.0:
		pause_timer -= delta
		_play_anim("stop")
		return

	_play_anim("moving")

	if move_mode == MoveMode.LINEAR:
		_process_linear(delta)
	elif move_mode == MoveMode.PATH:
		_process_path(delta)

# --- 模式 A：直线运动与形状投射 (Shape Cast) ---
func _process_linear(delta: float) -> void:
	var direction = move_direction.normalized()
	if direction == Vector2.ZERO or not collision_shape or not collision_shape.shape: 
		return

	# 构建形状投射查询参数
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	# 将检测框移动到平台前方 cast_distance 的位置
	query.transform = global_transform.translated(direction * cast_distance) 
	query.collision_mask = terrain_mask
	query.exclude = [get_rid()] # 排除平台自身的碰撞体

	# 进行形状交叠测试
	var result = space_state.intersect_shape(query)

	if result.size() > 0:
		# 前方碰撞框内存在地形，触发停顿与反转
		pause_timer = pause_duration
		move_direction = -move_direction
	else:
		# 前方安全，继续移动
		global_position += direction * move_speed * delta

# --- 模式 B：沿着 Path2D 移动 ---
func _process_path(delta: float) -> void:
	if not path_follow: return
	
	var curve_length = path_follow.get_parent().curve.get_baked_length()
	var step = (move_speed * delta) / curve_length
	
	path_follow.progress_ratio += step * current_path_sign
	global_position = path_follow.global_position

	if path_follow.progress_ratio >= 1.0 and current_path_sign == 1:
		current_path_sign = -1
		pause_timer = pause_duration
	elif path_follow.progress_ratio <= 0.0 and current_path_sign == -1:
		current_path_sign = 1
		pause_timer = pause_duration

# ==========================================
# 编辑器可视化绘图 (重点！)
# ==========================================
func _draw() -> void:
	# 只有在编辑器里，且是直线模式，且存在碰撞体时才绘制
	if not Engine.is_editor_hint() or move_mode != MoveMode.LINEAR:
		return
		
	var shape_node = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not shape_node or not shape_node.shape: 
		return

	var direction = move_direction.normalized()
	var offset = direction * cast_distance
	
	# 设置半透明绿色表示安全检测区
	var fill_color = Color(0.2, 0.8, 0.2, 0.3) 
	var outline_color = Color(0.2, 0.8, 0.2, 0.8)

	# 绘制中心指示线
	draw_line(shape_node.position, shape_node.position + offset, outline_color, 2.0)

	# 移动画笔到预测位置
	draw_set_transform(shape_node.position + offset, shape_node.rotation, shape_node.scale)

	# 根据碰撞体形状绘制预测框 (支持矩形和圆形)
	if shape_node.shape is RectangleShape2D:
		var extents = shape_node.shape.size / 2.0
		var rect = Rect2(-extents, shape_node.shape.size)
		draw_rect(rect, fill_color, true)
		draw_rect(rect, outline_color, false, 2.0)
	elif shape_node.shape is CircleShape2D:
		var radius = shape_node.shape.radius
		draw_circle(Vector2.ZERO, radius, fill_color)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, 2.0)
	
	# 重置画笔变换 (好习惯)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

# ==========================================
# 辅助方法
# ==========================================
func _setup_path_mode() -> void:
	if path_node.is_empty():
		push_error("MobilePlatform: 移动模式为 PATH，但未指定 Path2D 节点！")
		set_physics_process(false)
		return

	var p2d = get_node_or_null(path_node) as Path2D
	if not p2d:
		push_error("MobilePlatform: 找不到指定的 Path2D 节点！请检查路径。")
		set_physics_process(false)
		return

	path_follow = PathFollow2D.new()
	path_follow.loop = false
	path_follow.rotates = false 
	p2d.add_child(path_follow)
	
	path_follow.progress_ratio = start_progress_ratio
	global_position = path_follow.global_position

# 【修改】：玩家进入时激活
func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is Player: 
		is_active = true

# 【新增】：玩家离开时立刻停止
func _on_player_detector_body_exited(body: Node2D) -> void:
	if body is Player: 
		is_active = false
		_play_anim("stop") # 强制切回停止动画

func _play_anim(anim_name: String) -> void:
	if animation_player and animation_player.current_animation != anim_name:
		animation_player.play(anim_name)