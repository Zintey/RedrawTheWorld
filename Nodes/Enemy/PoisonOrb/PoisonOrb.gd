extends CharacterBody2D
class_name PoisonOrb

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_box: HitBox = $HitBox 
@onready var state_machine: StateMachine = $StateMachine

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	if hit_box:
		hit_box.area_entered.connect(_on_hit_box_area_entered)

func _on_hit_box_area_entered(area: Area2D) -> void:
	# 在空中飞行时，如果刚好砸到玩家，直接销毁（不留毒水）
	if area is HurtBox and state_machine.current_state.name == "start":
		state_machine.switch_to("end")

# --- 核心：抛物线初速度计算（L4和无人机全部通用） ---
func launch(target_pos: Vector2, dir: Vector2, flight_time: float = 0.8) -> void:
	var delta_x = target_pos.x - global_position.x
	var delta_y = target_pos.y - global_position.y
	
	# 1. 算出力道（原本完美命中需要的速度大小）
	var ideal_vx = delta_x / flight_time
	var ideal_vy = (delta_y - 0.5 * gravity * flight_time * flight_time) / flight_time
	var speed = Vector2(ideal_vx, ideal_vy).length()
	
	# 2. 终极一刀切：抛弃数学角度，强行顺着传进来的炮管方向飞！
	velocity = dir.normalized() * speed