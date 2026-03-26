extends U3State
class_name U3AttackState

@export_category("Sniper Attack Tactics")
@export var fire_cooldown: float = 2.0 ## 打完一枪后，蹲在地上的装填/冷却时间
@export var retreat_dist: float = 250.0 ## 危险距离，跟 Walk 状态保持一致！小于这个距离立刻站起来跑路

var wait_timer: float = 0.0
var is_waiting: bool = false # 标记当前是在播动画，还是在蹲着冷却

func enter() -> void:
	u3.velocity.x = 0
	_start_shoot_animation()

# 封装一个开火起手式，方便循环调用
func _start_shoot_animation() -> void:
	is_waiting = false
	wait_timer = fire_cooldown
	
	# 开枪前锁定玩家方向
	if u3.has_target():
		u3.flip_towards(u3.target_body.global_position)
		
	u3.animation_player.play("attack")
	# ⚠️ 记得在 attack 动画里插入 fire_bullet() 的轨道！

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta: float) -> void:
	# 1. 如果动画播完了，说明一发子弹打出去了，进入蹲姿等待(冷却)阶段
	if not u3.animation_player.is_playing() or u3.animation_player.current_animation != "attack":
		if not is_waiting:
			is_waiting = true # 动画停止的瞬间，进入等待状态，视觉上保持在动画最后一帧
		
		# 2. 在蹲姿等待期间，实时监控玩家的动向！
		if is_waiting:
			# 玩家丢了，立刻站起来
			if not u3.has_target():
				switched_to.emit(self, "stand_up")
				return
				
			var dist = abs(u3.target_body.global_position.x - u3.global_position.x)
			var y_dist = abs(u3.target_body.global_position.y - u3.global_position.y)
			
			# 玩家冲脸了 (距离太近)，或者跳到了完全打不到的高台/坑底 -> 强制收枪起立跑路！
			if dist < retreat_dist or y_dist > 150.0:
				switched_to.emit(self, "stand_up")
				return
				
			# 玩家依然在安全狙击区，开始走冷却倒计时
			wait_timer -= delta
			if wait_timer <= 0.0:
				# 冷却完毕，无缝再次开火！
				_start_shoot_animation()