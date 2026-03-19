extends Control
class_name RuneItemUI


@export var rune_data : RuneData
@onready var rune_icon: TextureRect = %RuneIcon

func init(_rune_data : RuneData) -> void:
	rune_data = _rune_data

func _process(delta: float) -> void:
	global_position = get_global_mouse_position() - Vector2(rune_icon.size.x / 2, rune_icon.size.y / 2)

var last_click_time: float = 0.0
const DOUBLE_CLICK_TIME: float = 0.3 # 0.3秒内连点两次算双击

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var current_time = Time.get_ticks_msec() / 1000.0 # 获取当前毫秒转成秒
		
		if current_time - last_click_time < DOUBLE_CLICK_TIME:
			# 两次点击间隔小于 0.3 秒，绝对是双击！
			print("【测试成功】手搓时间戳检测到双击：", rune_data.display_name if rune_data else "空")
			if rune_data != null:
				EventBus.rune_auto_equip_requested.emit(rune_data)
				
			# 重置时间，防止疯狂连点触发第三次
			last_click_time = 0.0 
		else:
			# 记下第一次点击的时间
			last_click_time = current_time

func _ready():
	z_index = 10000
	if rune_data != null:
		rune_icon.texture = rune_data.icon
