@tool
extends PanelContainer
class_name StateUI

const Health_Item = preload("uid://dumkogvctaypc")
const Stamina_Item = preload("uid://qqvdrcp8x3qc")

var health_component: HealthComponent
var stats_component: PlayerStatsComponent

@onready var health_box: HBoxContainer = %HealthBox
@onready var stamina_box: HBoxContainer = %StaminaBox

# 新的连续进度条节点
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var stamina_bar: TextureProgressBar = %StaminaBar

func init(_health_component: HealthComponent, _stats_component: PlayerStatsComponent) -> void:
	health_component = _health_component
	stats_component = _stats_component

func _ready() -> void:
	EventBus.player_die.connect(func () :
		init_health_box()
		init_stamina_box()
	)
	
	if health_component and stats_component:
		update_health_bar(health_component.current_hp, health_component.max_hp)
		update_stamina_bar(stats_component.current_stamina, stats_component.max_stamina)
		
		health_component.hp_changed.connect(update_health_bar)
		stats_component.stamina_changed.connect(update_stamina_bar)

# ==================== 新进度条逻辑 (支持浮点数) ====================
func update_health_bar(hp: float, max_hp: float) -> void:
	if is_instance_valid(health_bar):
		health_bar.max_value = max_hp
		health_bar.value = hp
	# 容错降级：继续调用旧盒子逻辑
	update_health_box(int(hp), int(max_hp)) 

func update_stamina_bar(stamina: float, max_stamina: float) -> void:
	if is_instance_valid(stamina_bar):
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina
	update_stamina_box(int(stamina), int(max_stamina)) 


# ==================== 旧方块逻辑区域 (完全保留) ====================
func init_health_box() -> void:
	for item in health_box.get_children(): item.queue_free()

func add_health_item() -> void:
	var health_item = Health_Item.instantiate()
	health_box.add_child(health_item)

func init_stamina_box() -> void:	
	for item in stamina_box.get_children(): item.queue_free()

func add_stamina_item() -> void:
	var stamina_item = Stamina_Item.instantiate()
	stamina_box.add_child(stamina_item)

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