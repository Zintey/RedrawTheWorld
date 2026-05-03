class_name SplitComponent extends RuneComponent

var split_cnt: int = 1
var has_split: bool = false 

func _ready():
	super()
	if core.has_meta("is_split") and core.get_meta("is_split"): return
	call_deferred("_spawn_clones")

func _spawn_clones():
	if has_split: return
	has_split = true
	
	var total_spread = deg_to_rad(60.0) 
	var start_angle = -total_spread / 2.0
	var angle_step = total_spread / float(max(1, split_cnt - 1))
	var base_dir = core.velocity_direction
	
	core.velocity_direction = base_dir.rotated(start_angle)
	core.velocity = core.velocity_direction * core.speed * core.speed_mul
	
	for i in range(1, split_cnt):
		var split_dir = base_dir.rotated(start_angle + i * angle_step)
		var clone = load(core.scene_file_path).instantiate()
		
		clone.set_meta("is_split", true) 
		core.get_parent().add_child(clone)
		
		clone.global_position = core.global_position 
		clone.velocity_direction = split_dir 
		
		# 修复：正确传入 active_modifiers 让克隆体动起来
		clone.init(core.core_rune_data, core.caster, core.active_modifiers)