class_name BounceComponent extends RuneComponent

var max_bounces: int = 0
var ray_cast: RayCast2D
const PROBE_DISTANCE: float = 5.0

func _ready():
	super()
	ray_cast = RayCast2D.new()
	ray_cast.target_position = Vector2.RIGHT * PROBE_DISTANCE
	ray_cast.collision_mask = 1 << 5 # 墙壁层
	ray_cast.hit_from_inside = true
	ray_cast.enabled = true
	add_child(ray_cast)
	
	core.on_tick.connect(_on_tick)
	core.on_check_destroy.connect(_on_check_destroy)

func _on_check_destroy(request: Dictionary):
	if request.get("hit_type") == "body":
		if max_bounces > 0:
			request.can_destroy = false

func _on_tick(delta: float):
	if max_bounces <= 0: return
	
	if core.velocity.length() > core.MIN_SPEED_EPS:
		var frame_move_distance = core.velocity.length() * delta
		var actual_probe_dist = max(PROBE_DISTANCE, frame_move_distance + 1.0)
		var world_endpoint = core.global_position + core.velocity.normalized() * actual_probe_dist
		
		ray_cast.target_position = ray_cast.to_local(world_endpoint)
		ray_cast.force_raycast_update()
		
		if ray_cast.is_colliding():
			max_bounces -= 1
			var normal = ray_cast.get_collision_normal()
			core.velocity = core.velocity.bounce(normal)
			core.global_position += normal * 0.6