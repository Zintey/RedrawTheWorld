extends Control
class_name CutsceneUI

@onready var video_player: VideoStreamPlayer = %VideoPlayer
@onready var skip_ui: Control = %SkipUI
@onready var skip_progress_bar: ProgressBar = %SkipProgressBar

const SKIP_HOLD_TIME: float = 1.0 # 需要长按 1 秒才能跳过
var current_hold_time: float = 0.0
var is_ending: bool = false

func _ready() -> void:
	skip_ui.modulate.a = 0.0 # 初始隐藏跳过提示
	video_player.finished.connect(_end_cutscene)

func play_video(stream: VideoStream) -> void:
	# 掐断原本的 BGM
	AudioManager.stop_bgm(1.0)
	
	video_player.stream = stream
	video_player.play()

func _process(delta: float) -> void:
	if is_ending: return
	
	# 长按空格跳过逻辑
	if Input.is_action_pressed("Key_Space"): # 确保这是你项目中配置的空格键行为
		current_hold_time += delta
		skip_ui.modulate.a = move_toward(skip_ui.modulate.a, 1.0, delta * 4.0)
		
		if current_hold_time >= SKIP_HOLD_TIME:
			_end_cutscene()
	else:
		# 松开后迅速回退进度
		current_hold_time = max(0.0, current_hold_time - delta * 2.0)
		if current_hold_time == 0:
			skip_ui.modulate.a = move_toward(skip_ui.modulate.a, 0.0, delta * 2.0)
			
	skip_progress_bar.value = current_hold_time / SKIP_HOLD_TIME

func _end_cutscene() -> void:
	if is_ending: return
	is_ending = true
	
	video_player.stop()
	EventBus.cutscene_finished.emit()
	
	# 简单淡出销毁
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(self.queue_free)