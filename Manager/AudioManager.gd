
extends Node



# --- 配置区域 ---

const SFX_POOL_SIZE = 8

const BUS_BGM = "Master"

const BUS_SFX = "Master"



# --- 资源库 (在这里配置你的音频文件路径) ---

# 格式: "调用名": preload("文件路径")

# 建议使用 preload 以便在游戏启动时预加载，避免播放时卡顿

var _sound_library: Dictionary = {

    # BGM 列表

    "bgm_menu": preload("res://Audio/BGM/bgm_main_menu.wav"),

    "bgm_battle": preload("res://Audio/BGM/bgm_battle.wav"),

    "bgm_idle1" : preload("res://Audio/BGM/bgm_idle1.wav"),

    "bgm_idle2" : preload("res://Audio/BGM/bgm_idle2.wav"),

    # SFX 列表

    "sfx_run": preload("res://Audio/SFX/sfx_run.wav"),

    "sfx_shoot": preload("res://Audio/SFX/sfx_shoot.wav"),

}



# --- 内部变量 ---

var _bgm_player: AudioStreamPlayer

var _sfx_players: Array[AudioStreamPlayer] = []

var _next_sfx_index: int = 0

var _current_bgm_key: String = "" # 记录当前播放的BGM名字



func _ready() -> void:

    # 1. 初始化 BGM 节点

    _bgm_player = AudioStreamPlayer.new()

    _bgm_player.name = "BGM_Player"

    _bgm_player.bus = BUS_BGM

    add_child(_bgm_player)

    

    # 2. 初始化 SFX 对象池

    for i in range(SFX_POOL_SIZE):

        var sfx_node = AudioStreamPlayer.new()

        sfx_node.name = "SFX_Player_" + str(i)

        sfx_node.bus = BUS_SFX

        add_child(sfx_node)

        _sfx_players.append(sfx_node)



# --- BGM 方法 ---



# 通过名字播放 BGM

func play_bgm(key: String, volume_db: float = 0.0) -> void:

    # 检查资源是否存在

    if not _sound_library.has(key):

        push_error("AudioManager: 未找到名为 '%s' 的 BGM" % key)

        return

        

    # 如果是同一首曲子且正在播放，则不重置

    if _current_bgm_key == key and _bgm_player.playing:

        _bgm_player.volume_db = volume_db

        return



    _bgm_player.stream = _sound_library[key]

    _bgm_player.volume_db = volume_db

    _bgm_player.play()

    _current_bgm_key = key



func stop_bgm() -> void:

    _bgm_player.stop()

    _current_bgm_key = ""



# --- SFX 方法 ---



# 通过名字播放 SFX

func play_sfx(key: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:

    if not _sound_library.has(key):

        push_error("AudioManager: 未找到名为 '%s' 的音效" % key)

        return

    

    var stream = _sound_library[key]

    var player = _sfx_players[_next_sfx_index]

    

    # 简单的轮替逻辑

    if player.playing:

        player.stop()

    

    player.stream = stream

    player.volume_db = volume_db

    player.pitch_scale = pitch_scale

    player.play()

    

    _next_sfx_index = (_next_sfx_index + 1) % SFX_POOL_SIZE



# 带有随机音调的播放方法 (用于高频重复音效，如脚步、枪声)

func play_sfx_random(key: String, min_pitch: float = 0.9, max_pitch: float = 1.1) -> void:

    var random_pitch = randf_range(min_pitch, max_pitch)

    play_sfx(key, 0.0, random_pitch)



# --- 扩展功能: 动态添加资源 ---

# 如果你想在游戏运行时动态加载资源(比如从DLC加载)，可以用这个方法

func register_sound(key: String, path: String) -> void:

    if ResourceLoader.exists(path):

        _sound_library[key] = load(path)

    else:

        push_error("AudioManager: 路径不存在 " + path)

