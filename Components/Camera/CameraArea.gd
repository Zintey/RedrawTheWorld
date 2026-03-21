extends Area2D
class_name CameraArea

@export_group("Camera Settings")
@export var target_zoom: Vector2 = Vector2(0.8, 0.8) # 区域镜头的缩放
@export var follow_speed: float = 5.0                # 区域镜头的跟随速度
@export var transition_time: float = 0.5             # 切入此区域的过渡时间

var boundary: Dictionary = {"left": 0, "right": 0, "top": 0, "bottom": 0}

func _ready():
	# ==========================================
	# 强制锁定碰撞层级与遮罩
	# ==========================================
	collision_layer = 1 # 区域自身在第 1 层
	collision_mask = 2  # 区域只检测第 2 层（玩家层）
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# 万一节点被动态销毁，确保把它从栈里踢出去
	tree_exiting.connect(_on_tree_exiting) 
	
	# 延迟一帧，确保全局坐标和缩放已全部初始化完毕
	call_deferred("_calculate_bounds")

func _calculate_bounds():
	var shape_node = null
	for child in get_children():
		if child is CollisionShape2D:
			shape_node = child
			break
			
	if shape_node and shape_node.shape is RectangleShape2D:
		var rect = shape_node.shape as RectangleShape2D
		var extents = rect.size / 2.0
		var global_center = shape_node.global_position
		
		boundary["left"] = global_center.x - extents.x
		boundary["right"] = global_center.x + extents.x
		boundary["top"] = global_center.y - extents.y
		boundary["bottom"] = global_center.y + extents.y
	else:
		push_warning("CameraArea (%s) 需要一个带有 RectangleShape2D 的 CollisionShape2D 子节点！" % name)

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		if has_node("/root/EventBus"):
			get_node("/root/EventBus").camera_area_entered.emit(self)

func _on_body_exited(body: Node2D):
	if body.name == "Player":
		if has_node("/root/EventBus"):
			get_node("/root/EventBus").camera_area_exited.emit(self)

func _on_tree_exiting():
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").camera_area_exited.emit(self)