extends Resource
class_name AudioClipData

@export var stream: AudioStream ## 原始音频文件

@export_group("剪辑设置 (Trimming)")
@export var start_time: float = 0.0 ## 起始播放时间 (秒)
@export var duration: float = 0.0 ## 持续时间 (秒)，0代表播到原始结尾
@export var fade_in: float = 0.02 ## 淡入时间 (秒)，防开头爆音
@export var fade_out: float = 0.05 ## 淡出时间 (秒)，防结尾爆音

@export_group("混音微调 (Mixing)")
@export_range(-24.0, 12.0) var volume_offset_db: float = 0.0 ## 单体音量微调