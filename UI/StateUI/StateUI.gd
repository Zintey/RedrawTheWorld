@tool
extends PanelContainer
class_name StateUI

const Health_Item = preload("uid://dumkogvctaypc")
const Stamina_Item = preload("uid://qqvdrcp8x3qc")

# 替换原本的 status_component
var health_component: HealthComponent
var stats_component: PlayerStatsComponent

@onready var health_box: HBoxContainer = %HealthBox
@onready var stamina_box: HBoxContainer = %StaminaBox

func init(_health_component: HealthComponent, _stats_component: PlayerStatsComponent) -> void:
	health_component = _health_component
	stats_component = _stats_component

func _ready() -> void:
	EventBus.player_die.connect(func () :
		init_health_box()
		init_stamina_box()
	)
	
	if health_component and stats_component:
		# 初始化显示
		update_health_box(health_component.current_hp, health_component.max_hp)
		update_stamina_box(stats_component.current_stamina, stats_component.max_stamina)
		
		# 连接信号驱动 UI 更新
		health_component.hp_changed.connect(update_health_box)
		stats_component.stamina_changed.connect(update_stamina_box)

func init_health_box() -> void:
	for item in health_box.get_children():
		item.queue_free()

func add_health_item() -> void:
	var health_item = Health_Item.instantiate()
	health_box.add_child(health_item)

func init_stamina_box() -> void:	
	for item in stamina_box.get_children():
		item.queue_free()

func add_stamina_item() -> void:
	var stamina_item = Stamina_Item.instantiate()
	stamina_box.add_child(stamina_item)

# 注意：为了匹配组件发出的 (current, max) 信号，参数顺序调整了
func update_health_box(hp: int, max_hp: int) -> void:
	for i in range(health_box.get_child_count(), max_hp):
		add_health_item()
	for i in range(max_hp):
		if i <= hp - 1:
			health_box.get_children()[i].show_item()
		else:
			if health_box.get_children()[i].has_method("hidden_item"):
				health_box.get_children()[i].hidden_item()

func update_stamina_box(stamina: int, max_stamina: int) -> void:
	for i in range(stamina_box.get_child_count(), max_stamina):
		add_stamina_item()
	for i in range(max_stamina):
		if i <= stamina - 1:
			stamina_box.get_children()[i].show_item()
		else:
			if stamina_box.get_children()[i].has_method("hidden_item"):
				stamina_box.get_children()[i].hidden_item()