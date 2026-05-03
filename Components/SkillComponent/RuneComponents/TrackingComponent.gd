class_name TrackingComponent extends RuneComponent

var tracking_strength: float = 0.0
var target: Node2D = null
var detect_area: Area2D

func _ready():
	super()
	core.on_tick.connect(_on_tick)
	
	detect_area = Area2D.new()
	detect_area.collision_mask = 1 << 4
	var coll = CollisionShape2D.new()
	coll.shape = CircleShape2D.new()
	coll.shape.radius = 500.0 
	detect_area.add_child(coll)
	add_child(detect_area)
	
	detect_area.area_entered.connect(_on_area_entered)
	detect_area.body_entered.connect(_on_body_entered)

func _on_tick(delta: float):
	if target and is_instance_valid(target):
		var speed_before = core.velocity.length()
		var dir = target.global_position - core.global_position
		
		if dir.length() > core.MIN_SPEED_EPS:
			core.velocity += dir.normalized() * tracking_strength * delta
			
			if speed_before > core.MIN_SPEED_EPS:
				core.velocity = core.velocity.normalized() * speed_before

func _on_area_entered(area: Area2D):
	if target == null and area is HurtBox:
		target = area.owner

func _on_body_entered(body: Node2D):
	if target == null and body.is_in_group("Enemy"):
		target = body