extends Node
class_name HealthComponent

## 血量变化时发出，方便 UI 更新血条
signal hp_changed(current_hp: float, max_hp: float)
## 血量归零时发出
signal died

@export var max_hp: float = 6
var current_hp: float

@export_group("sfx")
@export var recover_hp_sfx : AudioEvent
@export var extend_hp_sfx : AudioEvent

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

func recover_hp(amount: float) -> bool:
	if is_dead:
		return false
	if current_hp >= max_hp:
		return false
	current_hp += amount
	current_hp = min(max_hp, current_hp)
	hp_changed.emit(current_hp, max_hp)
	if (recover_hp_sfx):
		AudioManager.play_sfx(recover_hp_sfx);
	return true

func extend_hp(amount: float) -> bool:
	if max_hp >= 20: return false
	max_hp = min(max_hp + amount, 20)
	recover_hp(amount)
	hp_changed.emit(current_hp, max_hp)
	if (extend_hp_sfx):
		AudioManager.play_sfx(extend_hp_sfx);
	
	return true

func shorted_hp(amount: float) -> bool:
	max_hp -= amount
	hp_changed.emit(current_hp, max_hp)
	if max_hp <= 0: died.emit()
	return true