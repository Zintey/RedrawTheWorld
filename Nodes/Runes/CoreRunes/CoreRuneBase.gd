class_name CoreRuneBase extends HitBox

const PROBE_DISTANCE : float = 5.0 # 反弹探测距离
const MIN_SPEED_EPS: float = 0.0001

var modifier_handler : ModifierRuneHandler

var caster: PhysicsBody2D
var core_rune_data: RuneData

var velocity_direction: Vector2 = Vector2.RIGHT
@export var speed : float = 100.0
# @export var attack : float = 10.0

var velocity : Vector2 = Vector2.RIGHT * 1.0
var speed_mul: float = 1.0
var effect_list: Dictionary = {}

var is_teleport : bool = false
@export var teleport_point : Node2D = null

var rebound_cnt : int = 0

var can_tracking : bool = true
var tracking_strength : float = 0.0
var tracking_target : Node2D = null
# var tracking_direction : Vector2 = Vector2.ZERO

var ray_cast: RayCast2D

func _ready() -> void:
	ray_cast = RayCast2D.new()
	ray_cast.target_position = Vector2.RIGHT * PROBE_DISTANCE
	ray_cast.collision_mask = 1 << 4 | 1 << 5
	ray_cast.collide_with_areas = true 
	ray_cast.collide_with_bodies = true 
	ray_cast.enabled = true
	add_child(ray_cast)

func init(_data: RuneData, _caster: Node2D, _modifiers: Array[RuneData]):
	self.core_rune_data = _data
	self.caster = _caster
	modifier_handler = ModifierRuneHandler.new()
	
	global_position = caster.rune_emitter.emitter_point.global_position
	velocity_direction =  Vector2.LEFT if caster.stats_component.fire_facing_left else Vector2.RIGHT
	
	_apply_modifiers(_modifiers)
	
	velocity = velocity_direction * speed * speed_mul
	rotation = velocity_direction.angle()

	_start_action()



func _apply_modifiers(modifiers: Array[RuneData]):
	# print("current kill's modifier Array : ", modifiers)
	if modifiers.size() == 0:
		return
	var modifiers_copy = modifiers.duplicate()
	modifiers_copy.sort_custom(func(a : RuneData, b : RuneData) -> bool: 
		if a == null:
			return false
		if b == null:
			return true
		return a.priority > b.priority
	) 
	for modifier_rune_data in modifiers_copy:
		if modifier_rune_data == null:
			continue
		
		#print("current kill has ",modifier_rune_data.display_name)
		modifier_handler.apply_modifier(modifier_rune_data, self)

func _start_action():
	printerr("Error: _start_action must be implemented by subclass.")

func try_emit_teleport_signal():
	# if teleport_point:
		# print("has teleport point")
	if is_teleport:
		if teleport_point == null:
			EventBus.player_teleport_request.emit(global_position)
		else:
			EventBus.player_teleport_request.emit(teleport_point.global_position)

func _finish_rune_action():
	
	queue_free()


# func _physics_process(delta: float) -> void:

# 	if can_tracking and tracking_target:
# 		var speed_temp = velocity.length()
# 		velocity += (tracking_target.global_position - global_position).normalized() * tracking_strength * delta
# 		rotation = velocity.angle()
# 		velocity = velocity.normalized() * speed_temp

# 	var on_collide : bool = false
# 	var ray_cast = RayCast2D.new()


# 	if rebound_cnt > 0 and on_collide:
# 		rebound_cnt -= 1
	
	# global_position += velocity * delta



func _physics_process(delta: float) -> void:
	# ========== 追踪 ==========
	if can_tracking and tracking_target:
		var speed_before := velocity.length()
		
		var dir := tracking_target.global_position - global_position
		if dir.length() > MIN_SPEED_EPS:
			velocity += dir.normalized() * tracking_strength * delta
		
		if speed_before > MIN_SPEED_EPS and velocity.length() > MIN_SPEED_EPS:
			velocity = velocity.normalized() * speed_before
		
		if velocity.length() > MIN_SPEED_EPS:
			rotation = velocity.angle()


	# ========== 射线方向设置 ==========
	if velocity.length() > MIN_SPEED_EPS:
		var world_endpoint := global_position + velocity.normalized() * PROBE_DISTANCE
		ray_cast.target_position = ray_cast.to_local(world_endpoint)
	else:
		var world_endpoint := global_position + Vector2.RIGHT * 1
		ray_cast.target_position = ray_cast.to_local(world_endpoint)

	ray_cast.force_raycast_update()
	var on_collide := ray_cast.is_colliding()


	# ========== 反弹 ==========
	if rebound_cnt > 0 and on_collide and velocity.length() > MIN_SPEED_EPS:
		rebound_cnt -= 1
		
		var normal := ray_cast.get_collision_normal()
		velocity = velocity.bounce(normal)
		if velocity.length() > MIN_SPEED_EPS:
			rotation = velocity.angle()
	
		global_position += normal * 0.6 # 推开一点防止卡墙


	# ========== 移动 ==========
	global_position += velocity * delta
