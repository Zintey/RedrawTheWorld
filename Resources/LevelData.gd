extends Resource
class_name LevelData

@export var level_id: String = "level_1"
@export var level_name: String = "未命名层"
@export var level_icon: Texture2D

@export_group("Map Generation")
@export_dir var map_prefab_dir: String
@export var target_rooms: int = 15
@export var tolerance: int = 2
@export var leaf_room_allocation: Dictionary = {"boss": 1, "shop": 1, "treasure": 1}

@export_group("Routing")
@export var self_loop_weight: int = 0
@export var next_level_pool: Dictionary = {} # { LevelData : int }