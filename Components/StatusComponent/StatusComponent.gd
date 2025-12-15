class_name StatusComponent extends Node

signal hp_change(max_hp : int, hp : int)
signal stamina_change(max_stamina : int, stamina : int)

@export var hp : int = 6 :
	set(val):
		hp = val
		hp_change.emit(hp, _current_hp)
@export var mp : int = 10



var _current_hp : int = hp:
	set(val):
		_current_hp = val
		if _current_hp > hp:
			_current_hp = hp
		hp_change.emit(hp, _current_hp)
var _current_mp : int


@export var stamina_recovery_time : float = 5.0
@export var stamina : int = 6:
	set(val):
		stamina = val
		stamina_change.emit(stamina, _current_stamina)
var _current_stamina : int = stamina:
	set(val):
		_current_stamina = val
		if _current_stamina > stamina:
			_current_stamina = stamina
		stamina_change.emit(stamina, _current_stamina)

var walk_speed : float = 200.0
var run_speed : float = 300
var current_speed : float = walk_speed
var enable_move = true
var on_hit : bool = false
var is_die : bool = false

var floor_accelerate : float = run_speed / 0.2
var air_accelerate : float = floor_accelerate * 2.0
var current_accelerate : float = floor_accelerate

var jump_speed : float = -700.0
var drag_force : float = 1.38
var enable_jump = true
var can_jump = false

var fire_facing_left : bool = false
var facing_left : bool = false
var _force : Vector2 = Vector2.ZERO

@export var has_emitter : bool = false

func _ready() -> void:
	_current_hp = hp
	_current_mp = mp


func increase_max_hp(val : int):
	hp += val
	_current_hp = hp
	# hp_change.emit(hp, _current_hp)

func get_current_hp() -> int:
	return _current_hp
func get_current_mp() -> int:
	return _current_mp
func get_current_stamina() -> int:
	return _current_stamina
func decrease_hp(val : int) -> int:
	# var temp = _current_hp
	_current_hp -= val
	if _current_hp <= 0:
		_current_hp = 0
		is_die = true
	# if temp != _current_hp:
	# hp_change.emit(hp, _current_hp)
	return _current_hp

func recover_hp(val : int) -> int:
	# var temp = _current_hp
	_current_hp = max(_current_hp + val, hp)
	
	# if temp != _current_hp:
	# hp_change.emit(hp, _current_hp)
	return _current_hp


func increase_max_stamina(val : int):
	stamina += val
	# stamina_change.emit(stamina, _current_stamina)

func reduce_stamina(amount: int) -> int:
	_current_stamina = max(_current_stamina - amount, 0)
	# stamina_change.emit(stamina, _current_stamina)
	return _current_stamina
func recover_stamina(amount: int) -> int:
	_current_stamina = min(_current_stamina + amount, stamina)
	# stamina_change.emit(stamina, _current_stamina)
	return _current_stamina

func get_force() -> Vector2:
	return _force
func add_force(force : Vector2) -> void:
	_force += force

func _physics_process(delta: float) -> void:
	_force *= (1.0 / max(1.0, drag_force))
	if _force.length() <= 0.1:
		_force = Vector2.ZERO

#func _process(delta: float) -> void:
