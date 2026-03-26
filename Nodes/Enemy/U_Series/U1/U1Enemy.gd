extends EnemyBase
class_name U1Enemy

@export var move_speed: float = 80.0

# 预加载刚才做好的子弹场景
const BULLET_SCENE = preload("uid://cvnnsvksnlohk")

@onready var warn_area: Area2D = %WarnArea
@onready var bullet_spawn_point: Node2D = %BulletSpawnPoint # 记得在编辑器里建这个节点！

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
	
	# 接管枪口位置
	if bullet_spawn_point:
		bullet.global_position = bullet_spawn_point.global_position
	else:
		bullet.global_position = global_position
	
	# 沿当前朝向发射
	var fly_dir = Vector2.RIGHT * move_direction
	if bullet.has_method("launch"):
		bullet.launch(fly_dir)

# --- 索敌雷达 ---
func _on_warn_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = body

func _on_warn_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null