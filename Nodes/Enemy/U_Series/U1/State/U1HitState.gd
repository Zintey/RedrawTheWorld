extends U1State
class_name U1HitState

var hit_timer: float = 0.0

func enter() -> void:
	hit_timer = 0.0
	u1.velocity.x = 0
	
	# 如果你有受击动画，改为 play("hit")
	# 如果没有，用你写好的受击闪白 Shader
	var mat = u1.sprite_2d.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("hit", true)

func take_physics_process(delta: float) -> void:
	hit_timer += delta
	# 硬直 0.3 秒后恢复行动
	if hit_timer >= 0.3:
		var mat = u1.sprite_2d.material as ShaderMaterial
		if mat: mat.set_shader_parameter("hit", false)
		
		switched_to.emit(self, "idle")
		return
		
	super.take_physics_process(delta)