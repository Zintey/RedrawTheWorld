
class_name RuneData extends Resource

enum RuneType {
	ALL,
	TRIGGER,
	CORE,
	MODIFIER,
	LOCKON
};

@export var rune_id : String = "none"
@export var type : RuneType = RuneType.TRIGGER
@export var display_name : String = "符文名字"
@export var stamina_cost: float = 0.0
@export var stamina_cost_multiple : float = 1.0
@export var priority: int = 0
@export var parameters: Dictionary = {}



# UI
@export var icon : Texture2D = preload("res://Assets/RuneIcon/Temp/rune_icon1.png")
@export_multiline var description : String = "这是一个符文"
