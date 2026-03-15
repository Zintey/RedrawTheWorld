extends CutterState
class_name CutterAttackSprintState

enum Phase { AIMING, CHARGING, SPRINTING }

var current_phase: Phase
var state_timer: float = 1.0
var sprint_duration: float = 1.4 # 冲刺飞行的最大持续时间（超出后强制回idle）
var charge_time: float = 0.6     # 【你的需求】：精确的 0.6 秒蓄力动画时间

func enter() -> void:
	current_phase = Phase.AIMING
	state_timer = 0.0
	cutter.velocity = Vector2.ZERO
	# 在瞄准阶段，我们先播放 idle 动画（或者你可以专门建一个 aiming 动画）
	cutter.animation_player.play("idle")

func take_physics_process(delta: float) -> void:
	match current_phase:
		Phase.AIMING:
			_process_aiming(delta)
		Phase.CHARGING:
			_process_charging(delta)
		Phase.SPRINTING:
			_process_sprinting(delta)
			
	super.take_physics_process(delta)

# --- 阶段 1：平滑转身瞄准 ---
func _process_aiming(delta: float) -> void:
	cutter.velocity = Vector2.ZERO
	
	if not is_instance_valid(cutter.target_body):
		switched_to.emit(self, "idle")
		return
		
	var target_angle = (cutter.target_body.global_position - cutter.global_position).angle()
	var current_angle = cutter.rotatable_pivot.rotation
	
	# 使用 rotate_toward 进行平滑旋转，速度由 aim_speed 决定
	cutter.rotatable_pivot.rotation = rotate_toward(current_angle, target_angle, cutter.aim_speed * delta)
	
	# 计算当前角度和目标角度的夹角差
	var angle_diff = abs(angle_difference(cutter.rotatable_pivot.rotation, target_angle))
	
	# 如果角度差小于 0.05 弧度（约 2.8 度），视为瞄准完毕！
	if angle_diff < 0.05:
		current_phase = Phase.CHARGING
		state_timer = 0.0
		# 瞄准完毕，开始播放真实的 0.6 秒蓄力动画！
		cutter.animation_player.play("attack_sprint")

# --- 阶段 2：死锁蓄力 (0.6秒) ---
func _process_charging(delta: float) -> void:
	cutter.velocity = Vector2.ZERO
	state_timer += delta
	
	# 蓄力时间达到 0.6 秒，进入爆发冲刺！
	if state_timer >= charge_time:
		current_phase = Phase.SPRINTING
		state_timer = 0.0 # 计时器清零，留给冲刺曲线使用

# --- 阶段 3：爆发冲刺 ---
func _process_sprinting(delta: float) -> void:
	state_timer += delta
	var sprint_progress = state_timer / sprint_duration
	
	# 如果冲刺时间结束，或者整个动画彻底播完了，结束攻击
	if sprint_progress > 1.0 or not cutter.animation_player.is_playing():
		switched_to.emit(self, "idle")
		return
		
	# 计算曲线倍率
	var curve_multiplier = 1.0
	if cutter.sprint_curve:
		curve_multiplier = cutter.sprint_curve.sample(sprint_progress)
		
	# 朝着刚才锁死的角度冲锋
	var dash_dir = Vector2.RIGHT.rotated(cutter.rotatable_pivot.rotation)
	cutter.velocity = dash_dir * cutter.sprint_max_speed * curve_multiplier