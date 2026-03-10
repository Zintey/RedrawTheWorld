extends Marker2D
class_name EnemySpawner

@export var enemy_pool: Array[PackedScene] = []
@export var active_waves: Array[int] = [1]
@export var spawn_chance: float = 1.0
@export var random_radius: float = 0.0

func play_spawn_fx() -> void:
	pass

func spawn_enemy(current_wave: int, container: Node) -> void:
	if not current_wave in active_waves:
		return
		
	if randf() > spawn_chance:
		print("[Spawner Debug] Spawn skipped due to spawn_chance.")
		return
		
	play_spawn_fx()
	
	if enemy_pool.is_empty():
		print("[Spawner Debug] Warning: Enemy pool is empty!")
		return
		
	var enemy_scene = enemy_pool.pick_random()
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		enemy.add_to_group("Enemy")
		container.add_child(enemy)
		
		print("[Spawner Debug] Successfully spawned: ", enemy.name, " | Added to group 'Enemy': ", enemy.is_in_group("Enemy"))
		
		var offset = Vector2.ZERO
		if random_radius > 0:
			offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(0, random_radius)
			
		enemy.global_position = global_position + offset