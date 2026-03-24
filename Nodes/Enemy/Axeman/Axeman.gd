extends EnemyBase
class_name Axeman

@export_category("Axeman Core Settings")
@export var move_speed: float = 60.0 ## Boss 走路压迫玩家的速度
@export var attack_1_cd_max: float = 3.0 ## 剑气大招的冷却时间（秒）。决定了 Boss 连发剑气的频率。

var attack_1_timer: float = 0.0

const SWORD_AURA_SCENE = preload("uid://da6pix64oiur3") 

@onready var warn_area: Area2D = %WarnArea 

func _ready() -> void:
	super._ready() 
	
	if health_component:
		health_component.hp_changed.connect(_on_hp_changed)
		
	if warn_area:
		warn_area.body_entered.connect(_on_warn_area_body_entered)
		warn_area.body_exited.connect(_on_warn_area_body_exited)

func _physics_process(delta: float) -> void:
	super._physics_process(delta) 
	
	if attack_1_timer > 0:
		attack_1_timer -= delta

# --- 霸体闪白视觉表现 ---
func _on_hp_changed(_current: int, _max: int) -> void:
	var mat = sprite_2d.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("hit", true)
		var tween = create_tween()
		tween.tween_interval(0.1)
		tween.tween_callback(func(): mat.set_shader_parameter("hit", false))

# --- 剑气发射逻辑 ---
func fire_sword_aura() -> void:
	if not SWORD_AURA_SCENE: return
		
	var aura = SWORD_AURA_SCENE.instantiate()
	get_tree().current_scene.add_child(aura)
	aura.global_position = %SwordAuraPoint.global_position
	
	var fly_dir = Vector2.RIGHT * move_direction
	if aura.has_method("launch"):
		aura.launch(fly_dir)

# --- 雷达触发逻辑 ---
func _on_warn_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = body

func _on_warn_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null