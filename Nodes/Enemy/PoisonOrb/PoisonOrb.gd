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

# --- 核心：固定时间抛物线初速度计算 ---
func launch(target_pos: Vector2, flight_time: float = 0.8) -> void:
	var delta_x = target_pos.x - global_position.x
	var delta_y = target_pos.y - global_position.y
	
	# 1. 按照你的原版公式，算出完美命中需要的 x 和 y 速度
	var ideal_vx = delta_x / flight_time
	var ideal_vy = (delta_y - 0.5 * gravity * flight_time * flight_time) / flight_time
	
	# 2. 【核心提取】：我们只要这个抛物线速度的“大小（力道）”
	var speed = Vector2(ideal_vx, ideal_vy).length()
	
	# 3. 【视觉强扭】：强制将实际速度的方向，设为毒球自身的全局旋转角度！
	# 这样就算算出来的抛物线是往后抛的，也会被强行掰到炮管的正前方！
	velocity = Vector2.RIGHT.rotated(global_rotation) * speed