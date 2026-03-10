# CommonStopState.gd
# 合并 CannonStop1State / CannonStop2State / TrackedCutterStopState。
# 这三个状态唯一的差别是等待时间和结束后去哪个状态，用 @export 配置即可。
# 同时修复了原来 Timer.new() 动态创建的问题——改用场景树里预置的 Timer。
#
# 迁移方式：
#   1. 在各敌人场景的 StateMachine 下，把原来的 Stop1/Stop2/Stop 节点脚本换成这个
#   2. 在 Inspector 里设置 stop_time 和 next_state
#   3. 在场景树里给 StateMachine 下的这个 State 节点添加一个子 Timer，命名为 "StopTimer"
#
# 为什么用场景预置 Timer 而不是 Timer.new()：
#   动态 new() 出来的 Timer 在 await timeout 之前如果状态已经切走，
#   await 回调依然会执行，可能触发一个已经不合时宜的 switched_to，
#   导致状态机跳到错误状态。预置 Timer 在 exit() 里 stop() 可以安全打断。

extends EnemyState
class_name CommonStopState

@export var stop_time:  float  = 1.0
@export var next_state: String = "idle"
# 可选：stop 期间如果被打中，是否打断并切到 hit 状态
@export var interruptible_by_hit: bool = true

@onready var stop_timer: Timer = $StopTimer

func enter() -> void:
	agent.animation_player.play("idle")
	stop_timer.wait_time = stop_time
	stop_timer.start()

func exit() -> void:
	stop_timer.stop()

func take_process(delta: float) -> void:
	if interruptible_by_hit and agent.check_on_hit():
		switched_to.emit(self, "hit")
		return
	if stop_timer.time_left == 0 and not stop_timer.is_stopped():
		return  # timer 还没结束
	super.take_process(delta)

func _on_stop_timer_timeout() -> void:
	switched_to.emit(self, next_state)
