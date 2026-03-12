extends Marker2D
class_name EnemySpawner

# 新增两个信号，用于向房间汇报生成状态
signal spawn_started
signal enemy_spawned(enemy_node: Node)

@export var enemy_pool: Array[PackedScene] = []
@export var active_waves: Array[int] = [1]
@export var spawn_chance: float = 1.0
@export var random_radius: float = 0.0

@export_group("Juice Config")
@export var max_spawn_delay: float = 0.4 # 新增：错峰生成的最大延迟时间

@export var Enemy_Coming_Pre = preload("uid://cp23v1aystrty")

func play_spawn_fx() -> void:
	pass

func spawn_enemy(current_wave: int, container: Node) -> void:
	if not current_wave in active_waves:
		return
		
	if randf() > spawn_chance:
		print("[Spawner Debug] Spawn skipped due to spawn_chance.")
		return
		
	if enemy_pool.is_empty():
		print("[Spawner Debug] Warning: Enemy pool is empty!")
		return
		
	# 核心改动：必须在任何延迟之前告诉房间“我准备开始摇人了，这期间绝对不许开门”
	# 否则 RoomBase 检查时会因为还没延迟结束而直接判定波次清空
	spawn_started.emit()
		
	# 新增：错峰生成逻辑，随机等待一小段时间
	var delay = randf_range(0.0, max_spawn_delay)
	if delay > 0:
		await get_tree().create_timer(delay).timeout
		
	play_spawn_fx()
	
	var enemy_scene = enemy_pool.pick_random()
	if enemy_scene:
		var enemy_coming_ins : EnemyComing = Enemy_Coming_Pre.instantiate()
		add_child(enemy_coming_ins)
		
		# 等待特效播放完毕发出的 start_spawn 信号
		await enemy_coming_ins.start_spawn
		
		var enemy : EnemyBase = enemy_scene.instantiate()
		container.add_child(enemy)
		
		print("[Spawner Debug] Successfully spawned: ", enemy.name)
		
		var offset = Vector2.ZERO
		if random_radius > 0:
			offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(0, random_radius)
			
		enemy.global_position = global_position + offset
		enemy.velocity = Vector2.ZERO # 防止生成瞬间受重力影响下落过快
		
		# 核心改动：真正的敌人落地，交接给房间去监听 died 信号
		enemy_spawned.emit(enemy)
