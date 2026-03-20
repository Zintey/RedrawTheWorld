extends Node2D
class_name DestructibleProp

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: HurtBox = $HurtBox
@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: Node = $StateMachine

func _ready() -> void:
	# 方案1：监听 HurtBox 的挨打信号 (推荐这个，专门针对挨打，带1个参数)
	if hurt_box:
		hurt_box.took_damage.connect(func(_amount): 
			state_machine.switch_to("hit")
		)
		
	# 监听 HealthComponent 的死亡信号 (没有参数)
	if health_component:
		health_component.died.connect(func(): 
			state_machine.switch_to("die")
		)
		