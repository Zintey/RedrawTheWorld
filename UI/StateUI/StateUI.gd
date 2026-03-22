@tool
extends PanelContainer
class_name StateUI

const Health_Item = preload("uid://dumkogvctaypc")
const Stamina_Item = preload("uid://qqvdrcp8x3qc")

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
		update_health_box(health_component.current_hp, health_component.max_hp)
		update_stamina_box(stats_component.current_stamina, stats_component.max_stamina)
		
		health_component.hp_changed.connect(update_health_box)
		stats_component.stamina_changed.connect(update_stamina_box)

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

# ==================== 离散 UI 核心逻辑 (支持半格) ====================
func update_health_box(hp: float, max_hp: float) -> void:
	var max_hearts = ceil(max_hp) # 向上取整，比如 2.5 也是 3 个格子
	for i in range(health_box.get_child_count(), max_hearts):
		add_health_item()
		
	for i in range(health_box.get_child_count()):
		var item = health_box.get_children()[i]
		if i >= max_hearts:
			item.hide()
			continue
		item.show()
		
		# 判断全、半、空状态
		if hp >= i + 1.0:
			if item.has_method("show_full"): item.show_full()
		elif hp > i:
			if item.has_method("show_half"): item.show_half()
		else:
			if item.has_method("show_empty"): item.show_empty()

func update_stamina_box(stamina: float, max_stamina: float) -> void:
	var max_stars = ceil(max_stamina)
	for i in range(stamina_box.get_child_count(), max_stars):
		add_stamina_item()
		
	for i in range(stamina_box.get_child_count()):
		var item = stamina_box.get_children()[i]
		if i >= max_stars:
			item.hide()
			continue
		item.show()
		
		if stamina >= i + 1.0:
			if item.has_method("show_full"): item.show_full()
		elif stamina > i:
			if item.has_method("show_half"): item.show_half()
		else:
			if item.has_method("show_empty"): item.show_empty()