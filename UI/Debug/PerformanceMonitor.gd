extends VBoxContainer

# 使用 @onready 自动获取子节点
@onready var perf_label = $PerfLabel
@onready var toggle_button = $ToggleButton

func _ready() -> void:
	# 用代码连接按钮的“按下”信号，免去在编辑器里连线的麻烦
	toggle_button.pressed.connect(_on_toggle_button_pressed)

func _process(_delta: float) -> void:
	# 优化：如果面板被隐藏了，就不进行计算，节省性能
	if not perf_label.visible:
		return
		
	# 1. 获取基础数据
	var fps := Engine.get_frames_per_second()
	var process_time := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_time := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var static_mem := OS.get_static_memory_usage() / 1048576.0 
	var vram := Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	
	# 2. 更新文本
	perf_label.text = "=== 性能监测 ===\n"
	perf_label.text += "FPS: %d\n" % fps
	perf_label.text += "逻辑耗时: %.2f ms\n" % process_time
	perf_label.text += "物理耗时: %.2f ms\n" % physics_time
	perf_label.text += "内存: %.2f MB\n" % static_mem
	perf_label.text += "显存: %.2f MB\n" % vram
	perf_label.text += "Draw Calls: %d" % draw_calls

# 按钮被点击时触发的函数
func _on_toggle_button_pressed() -> void:
	# 切换 Label 的可见性 (如果显示就隐藏，如果隐藏就显示)
	perf_label.visible = !perf_label.visible