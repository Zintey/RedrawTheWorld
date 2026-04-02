extends Node
class_name HealthComponent

## 血量变化时发出，方便 UI 更新血条
signal hp_changed(current_hp: float, max_hp: float)
## 血量归零时发出
signal died

@export var max_hp: float = 6
var current_hp: float

var is_dead: bool = false

func _ready() -> void:
	current_hp = max_hp

func decrease_hp(amount: float) -> void:
	if is_dead:
		return
		
	current_hp -= amount
	current_hp = max(0, current_hp)
	hp_changed.emit(current_hp, max_hp)
	
	if current_hp == 0:
		is_dead = true
		died.emit()

func recover_hp(amount: float) -> void:
	if is_dead:
		return
		
	current_hp += amount
	current_hp = min(max_hp, current_hp)
	hp_changed.emit(current_hp, max_hp)