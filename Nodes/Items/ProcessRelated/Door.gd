extends StaticBody2D
class_name Door

# 真实的物理状态锁，默认门是关着的 [cite: 6]
var is_open: bool = false

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	pass

# 增加了 skip_anim 参数，用于在地图生成时瞬间把门状态切换到最后
func open(play_sound: bool = true, skip_anim: bool = false) -> void:
	# 状态拦截：如果门已经是开着的，直接忽略指令，防止重播动画
	if is_open:
		return
		
	is_open = true
	animation_player.play("open")
	
	if skip_anim:
		# 直接让 AnimationPlayer 快进到动画的末尾（第 0.3 秒，此时碰撞体已关闭） [cite: 11]
		animation_player.advance(animation_player.current_animation_length)
	elif play_sound and audio_stream_player:
		audio_stream_player.play()

func close(play_sound: bool = true, skip_anim: bool = false) -> void:
	# 状态拦截：如果门已经是关着的，直接忽略
	if not is_open:
		return
		
	is_open = false
	animation_player.play("close")
	
	if skip_anim:
		# 直接让 AnimationPlayer 快进到关门动画末尾 [cite: 8]
		animation_player.advance(animation_player.current_animation_length)
	elif play_sound and audio_stream_player:
		audio_stream_player.play()