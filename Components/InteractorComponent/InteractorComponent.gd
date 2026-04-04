class_name InteractorComponent extends Area2D

@export var pick_up_sfx : AudioEvent

var items_in_range: Array[InteractableArea] = []
var focused_item: InteractableArea = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if area is InteractableArea:
		items_in_range.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area is InteractableArea:
		items_in_range.erase(area)
		# 如果离开的正是当前激活的焦点，立刻取消它的光环
		if focused_item == area:
			focused_item.unfocused.emit()
			focused_item = null

func _physics_process(delta: float) -> void:
	if items_in_range.is_empty(): 
		return
		
	var closest_item: InteractableArea = null
	var closest_dist = INF
	
	# 遍历计算距离最近的交互物
	for item in items_in_range:
		var dist = global_position.distance_to(item.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_item = item
			
	# 如果焦点发生了转移，进行权力交接
	if closest_item != focused_item:
		if is_instance_valid(focused_item):
			focused_item.unfocused.emit()
		focused_item = closest_item
		if is_instance_valid(focused_item):
			focused_item.focused.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") and is_instance_valid(focused_item):
		focused_item.interacted.emit(get_parent())
		if (pick_up_sfx):
			AudioManager.play_sfx(pick_up_sfx)