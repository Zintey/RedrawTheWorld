extends LevelBase

var enemys
var enemy_remain_cnt : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemys = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemys:
		enemy_remain_cnt += 1
		enemy.die_signal.connect(func() :
			enemy_remain_cnt -= 1
		)


var done : bool = false
func _process(delta: float) -> void:
	# if boss.status_component.is_die and !done:
	if enemy_remain_cnt <= 0 and !done:
		done = true
		for door : Door in get_tree().get_nodes_in_group("Door"):
			door.on_open_door()
			await get_tree().create_timer(0.2).timeout
			# await 0.1
