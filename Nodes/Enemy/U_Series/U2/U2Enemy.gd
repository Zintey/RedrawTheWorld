extends EnemyBase
class_name U2Enemy

@export_category("U2 Melee Settings")
@export var move_speed: float = 120.0 ## 疯狗移速！一定要比 U1 快，给玩家压力！

@onready var warn_area: Area2D = %WarnArea

func _ready() -> void:
	super._ready()
	
	# 连接霸体闪白视觉表现
	if health_component:
		health_component.hp_changed.connect(_on_hp_changed)
		
	# 连接那根 800x200 的超长视野雷达！
	if warn_area:
		warn_area.body_entered.connect(_on_warn_area_body_entered)
		warn_area.body_exited.connect(_on_warn_area_body_exited)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

# --- 挨打闪白视觉 ---
func _on_hp_changed(_current: int, _max: int) -> void:
	var mat = sprite_2d.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("hit", true)
		var tween = create_tween()
		tween.tween_interval(0.1)
		tween.tween_callback(func(): mat.set_shader_parameter("hit", false))

# --- 索敌雷达 ---
func _on_warn_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = body

func _on_warn_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null