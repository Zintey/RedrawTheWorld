# CommonHitState.gd
# 把 CannonHitState / DroneHitState / TrackedCutterHitState 三份几乎相同的代码合并成这一个。
# Eden 的 hit 状态也直接用这个，不需要单独写。
#
# 用法：在 Godot 编辑器里，把这个脚本挂到各个敌人 StateMachine 下的 "hit" 节点上，
# 然后在 Inspector 里配置 next_state_on_alive（默认 "idle"）即可。
# Drone 的 hit 之后要回到 "warn_move"，把 next_state_on_alive 改成 "warn_move" 就行。

extends EnemyState
class_name CommonHitState

const HIT_DUST_SCENE = preload("res://Nodes/Items/HitDust/HitDust.tscn")

# 在编辑器里按需配置，不用改代码
@export var next_state_on_alive: String = "idle"
@export var next_state_on_die:   String = "die"

func enter() -> void:
	agent.animation_player.play("hit")
	agent.sprite_2d.material.set_shader_parameter("hit", true)

	var hit_dust: Node2D = HIT_DUST_SCENE.instantiate()
	hit_dust.global_position = agent.global_position
	get_tree().current_scene.add_child(hit_dust)

	super()

func exit() -> void:
	agent.sprite_2d.material.set_shader_parameter("hit", false)
	agent.status_component.on_hit = false
	super()

func take_physics_process(delta: float) -> void:
	super.take_physics_process(delta)

func take_process(delta: float) -> void:
	if agent.check_is_die():
		switched_to.emit(self, next_state_on_die)
		return
	if not agent.animation_player.is_playing():
		switched_to.emit(self, next_state_on_alive)
		return
	super.take_process(delta)
