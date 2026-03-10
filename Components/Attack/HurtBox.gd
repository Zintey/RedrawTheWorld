extends Area2D
class_name HurtBox

signal took_damage(amount: int)

## 关联的生命组件。把它拖进来，HurtBox 挨打时会自动扣血！
@export var health_component: HealthComponent
## 无敌帧开关（玩家闪避，或怪物受伤后的短暂闪烁时设为 true）
@export var is_invincible: bool = false

func _ready() -> void:
	# 代码里自动连接信号，省去你在编辑器里手动连线的麻烦
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if is_invincible:
		return
		
	# 核心：只对 HitBox 做出反应
	if area is HitBox:
		take_damage(area.damage)

func take_damage(amount: int) -> void:
	took_damage.emit(amount)
	
	# 如果你在编辑器里给它绑定了 HealthComponent，它就自动扣血
	if health_component:
		health_component.decrease_hp(amount)