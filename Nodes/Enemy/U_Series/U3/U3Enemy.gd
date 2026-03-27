extends EnemyBase
class_name U3Enemy

@export_category("Sniper Settings")
@export var move_speed: float = 70.0 ## 狙击手移速较慢

# 姿态记忆核心：当前是否处于蹲下状态？
var is_crouching: bool = false 

# 直接复用 U1 的光束弹场景！(请替换为实际的 UID 或路径)
const BULLET_SCENE = preload("uid://cvnnsvksnlohk")

@onready var warn_area: Area2D = %WarnArea
@onready var bullet_spawn_point: Node2D = %BulletSpawnPoint # 记得在编辑器里加上这个节点！

func _ready() -> void:
	super._ready()
	
	if warn_area:
		warn_area.body_entered.connect(_on_warn_area_body_entered)
		warn_area.body_exited.connect(_on_warn_area_body_exited)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

# --- 动画调用的开火函数 ---
func fire_bullet() -> void:
	if not BULLET_SCENE: return
	
	var bullet = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	if bullet_spawn_point:
		bullet.global_position = bullet_spawn_point.global_position
	else:
		bullet.global_position = global_position
	
	# 狙击枪子弹速度极快！可以考虑在子弹场景把 speed 调高点，或者在这里临时覆盖：
	# if bullet.get("speed") != null: bullet.speed = 1000.0
	
	var fly_dir = Vector2.RIGHT * move_direction
	if bullet.has_method("launch"):
		bullet.set_speed(1000)
	if bullet.has_method("launch"):
		bullet.launch(fly_dir)

# --- 索敌雷达 ---
func _on_warn_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# player_in_range = body
		acquire_target(body)

func _on_warn_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		# player_in_range = null
		lose_target(body)