class_name CoreRuneBase extends HitBox

const PROBE_DISTANCE : float = 5.0 
const MIN_SPEED_EPS: float = 0.0001
const CATCH_DISTANCE: float = 30.0 # 判定接住回旋镖的距离

var modifier_handler : ModifierRuneHandler
var caster: PhysicsBody2D
var core_rune_data: RuneData

var velocity_direction: Vector2 = Vector2.RIGHT
@export var speed : float = 100.0

var velocity : Vector2 = Vector2.RIGHT * 1.0
var speed_mul: float = 1.0
var effect_list: Dictionary = {}

# 生命时间
@export var life_time : float = 0.5
var life_time_mul : float = 1.0

# 传送
var is_teleport : bool = false
@export var teleport_point : Node2D = null

# 反弹
var rebound_cnt : int = 0
var ray_cast: RayCast2D

# 追踪
var can_tracking : bool = true
var tracking_strength : float = 0.0
var tracking_target : Node2D = null

# 重力
const GRAVITY = 980
var can_gravity : bool = true
var current_gravity : int = 0

# 分裂
var split_cnt : int = 1
var is_split : bool = false

# 回旋
var can_swirl : bool = true
var need_swirl : bool = false
var swirl_speed_multiplier : float = 1.5 
var last_caster_pos : Vector2 = Vector2.ZERO 
var is_returning : bool = false 

# 穿透
var can_penetrate : bool = true
var need_penetrate : bool = false

# 击中回能
var absorb_stamina : int = 0

# 巨大化
@export var bigger_multiple_base : float = 1.0
var bigger_multiple : float = 1.0
var bigger_timer : Timer

# 正弦化移动
var sin_moving_amount : float = 0.0
var sin_moving_dir : Vector2
var sin_moving_time : float = 0.0    # 用来控制正弦运动 

func _ready() -> void:
	ray_cast = RayCast2D.new()
	ray_cast.target_position = Vector2.RIGHT * PROBE_DISTANCE
	ray_cast.collision_mask = 1 << 5
	ray_cast.collide_with_areas = true 
	ray_cast.collide_with_bodies = true 
	ray_cast.hit_from_inside = true
	ray_cast.enabled = true
	add_child(ray_cast)

	# 巨大化
	bigger_timer = Timer.new()
	bigger_timer.wait_time = 0.01
	bigger_timer.one_shot = false
	add_child(bigger_timer)
	bigger_timer.timeout.connect(func (): scale *= bigger_multiple)
	bigger_timer.start()

func init(_data: RuneData, _caster: Node2D, _modifiers: Array[RuneData]):
	self.core_rune_data = _data
	self.caster = _caster
	modifier_handler = ModifierRuneHandler.new()
	
	if is_instance_valid(caster):
		last_caster_pos = caster.global_position
	
	if not is_split:
		global_position = caster.rune_emitter.emitter_point.global_position
		velocity_direction = Vector2.LEFT if caster.stats_component.fire_facing_left else Vector2.RIGHT
	
	_apply_modifiers(_modifiers)
	
	# 【穿透核心】：如果带有穿透符文，直接罢工物理射线，因为它能穿墙，不需要反弹探测了
	if need_penetrate:
		ray_cast.enabled = false
	
	if not is_split:
		velocity_direction = (get_global_mouse_position() - caster.global_position).normalized()
		
		if split_cnt > 1:
			var total_spread = deg_to_rad(60.0) 
			var start_angle = -total_spread / 2.0
			var angle_step = total_spread / float(split_cnt - 1)
			var base_dir = velocity_direction
			velocity_direction = base_dir.rotated(start_angle)
			
			for i in range(1, split_cnt):
				var split_dir = base_dir.rotated(start_angle + i * angle_step)
				var clone = load(self.scene_file_path).instantiate()
				clone.is_split = true
				clone.global_position = self.global_position 
				clone.velocity_direction = split_dir 
				get_parent().call_deferred("add_child", clone)
				clone.call_deferred("init", _data, _caster, _modifiers)

	velocity = velocity_direction * speed * speed_mul
	sin_moving_dir = velocity.rotated(PI / 2).normalized()
	rotation = velocity_direction.angle()

	_start_action()

func _apply_modifiers(modifiers: Array[RuneData]):
	if modifiers.size() == 0: return
	var modifiers_copy = modifiers.duplicate()
	modifiers_copy.sort_custom(func(a : RuneData, b : RuneData) -> bool: 
		if a == null: return false
		if b == null: return true
		return a.priority > b.priority
	) 
	for modifier_rune_data in modifiers_copy:
		if modifier_rune_data == null: continue
		modifier_handler.apply_modifier(modifier_rune_data, self)

func _start_action():
	printerr("Error: _start_action must be implemented by subclass.")

func try_emit_teleport_signal():
	if is_teleport:
		if teleport_point == null:
			EventBus.player_teleport_request.emit(global_position)
		else:
			EventBus.player_teleport_request.emit(teleport_point.global_position)

func _on_area_entered(area: Area2D) -> void:
	print("enter")
	if area is HurtBox:
		caster.stats_component.recover_stamina(absorb_stamina)

func _on_body_entered(body: Node2D) -> void:
	pass

func _finish_rune_action():
	if can_swirl and need_swirl and not is_returning:
		is_returning = true
		ray_cast.enabled = false 
		return

	queue_free()

func _physics_process(delta: float) -> void:
	# ==================== 回旋状态 VIP通道 ====================
	if is_returning:
		if is_instance_valid(caster):
			last_caster_pos = caster.global_position
			
		var dir_to_target = last_caster_pos - global_position
		
		if dir_to_target.length() <= CATCH_DISTANCE:
			_finish_rune_action() 
			return
			
		velocity = dir_to_target.normalized() * (speed * speed_mul * swirl_speed_multiplier)


		
	# ==================== 正常飞行状态 ====================
	else:
		if can_gravity:
			velocity.y += current_gravity * delta

		if can_tracking and tracking_target and is_instance_valid(tracking_target):
			var speed_before := velocity.length()
			var dir := tracking_target.global_position - global_position
			if dir.length() > MIN_SPEED_EPS:
				velocity += dir.normalized() * tracking_strength * delta
			if speed_before > MIN_SPEED_EPS and velocity.length() > MIN_SPEED_EPS:
				velocity = velocity.normalized() * speed_before

		# 【穿透核心】：如果没有穿透属性，才去管探测墙壁和反弹的事！
		if not need_penetrate:
			if velocity.length() > MIN_SPEED_EPS:
				var frame_move_distance = velocity.length() * delta
				var actual_probe_dist = max(PROBE_DISTANCE, frame_move_distance + 1.0)
				var world_endpoint = global_position + velocity.normalized() * actual_probe_dist
				ray_cast.target_position = ray_cast.to_local(world_endpoint)
			else:
				ray_cast.target_position = ray_cast.to_local(global_position + Vector2.RIGHT * 1)

			ray_cast.force_raycast_update()
			var on_collide := ray_cast.is_colliding()

			if rebound_cnt > 0 and on_collide and velocity.length() > MIN_SPEED_EPS:
				rebound_cnt -= 1
				var normal := ray_cast.get_collision_normal()
				velocity = velocity.bounce(normal)
				global_position += normal * 0.6 

	var final_velocity : Vector2 = velocity
	final_velocity += sin_moving_amount * sin_moving_dir * sin(sin_moving_time * 30)
	final_velocity = final_velocity.normalized() * velocity.length()
	sin_moving_time += delta

	if final_velocity.length() > MIN_SPEED_EPS:
		rotation = final_velocity.angle()
	global_position += final_velocity * delta
