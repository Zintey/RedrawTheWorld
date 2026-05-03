# CoreRuneBase.gd
class_name CoreRuneBase extends HitBox

signal on_tick(delta: float)
signal on_hit(target: Node2D)
signal on_destroyed()
signal on_life_timeout()
signal on_check_destroy(request: Dictionary)

const MIN_SPEED_EPS: float = 0.0001

var modifier_handler: ModifierRuneHandler
var caster: PhysicsBody2D
var core_rune_data: RuneData
var active_modifiers: Array[RuneData] = [] 

var velocity_direction: Vector2 = Vector2.RIGHT
@export var speed: float = 100.0
@export var life_time: float = 0.5

var velocity: Vector2 = Vector2.RIGHT * 1.0
var speed_mul: float = 1.0
var life_time_mul: float = 1.0

func _ready() -> void:
	pass

func init(_data: RuneData, _caster: Node2D, _modifiers: Array[RuneData]):
	self.core_rune_data = _data
	self.caster = _caster
	self.active_modifiers = _modifiers
	modifier_handler = ModifierRuneHandler.new()
	
	_apply_modifiers(_modifiers)
	
	velocity = velocity_direction * speed * speed_mul
	rotation = velocity_direction.angle()

	_start_action()

func _apply_modifiers(modifiers: Array[RuneData]):
	if modifiers.size() == 0: return
	var modifiers_copy = modifiers.duplicate()
	modifiers_copy.sort_custom(func(a, b): 
		if a == null: return false
		if b == null: return true
		return a.priority > b.priority
	) 
	for modifier_rune_data in modifiers_copy:
		if modifier_rune_data == null: continue
		modifier_handler.apply_modifier(modifier_rune_data, self)

func _start_action():
	printerr("Error: _start_action must be implemented by subclass.")

func _physics_process(delta: float) -> void:
	on_tick.emit(delta)

	if velocity.length() > MIN_SPEED_EPS:
		rotation = velocity.angle()
	global_position += velocity * delta

func _finish_rune_action():
	on_life_timeout.emit()
	
	var request = {"can_destroy": true, "hit_type": "timeout"}
	on_check_destroy.emit(request)
	
	if request.can_destroy:
		on_destroyed.emit()
		queue_free()