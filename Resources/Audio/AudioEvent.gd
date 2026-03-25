extends Resource
class_name AudioEvent

@export var clips: Array[AudioClipData] = [] ## 音频切片池，触发时随机抽取

@export_group("全局控制 (Global)")
@export_range(-40.0, 12.0) var base_volume_db: float = 0.0 ## 基础音量
@export_range(0.0, 1.0) var pitch_randomness: float = 0.05 ## 随机音高波动 (+/-)
@export var bus_name: StringName = &"SFX" ## 混音总线名称

@export_group("并发与抢占 (Concurrency)")
@export var max_instances: int = 3 ## 同屏最大允许发声数
@export var priority: int = 50 ## 优先级 (0-100，越大越优先)