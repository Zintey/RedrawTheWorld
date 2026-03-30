extends Node

# --- 新增：玩家组件就绪信号 ---
# 传递四大核心组件，彻底替代 GameInstance
signal player_components_ready(health_comp: Node, stats_comp: Node, inv_comp: Node, skill_comp: Node)

# UI 管理符文和技能拖拽的信号
signal rune_drag_started(rune_data : RuneData, start_slot : RuneSlotUI)
signal rune_drag_ended(rune_data : RuneData, start_slot : RuneSlotUI)
signal skill_drag_started(skill_data : SkillData, start_slot : SkillSlotUI)
signal skill_drag_ended(skill_data : SkillData, start_slot : SkillSlotUI)
signal mouse_in_rune_slot(rune_slot : RuneSlotUI)
signal mouse_out_rune_slot()
signal mouse_in_skill_slot(skill_slot : SkillSlotUI)
signal mouse_out_skill_slot()


# --- 快捷装卸信号 ---
signal rune_quick_unequip_requested(rune_data : RuneData)
signal rune_auto_equip_requested(rune_data : RuneData)
signal rune_auto_equipped(rune_data : RuneData)

signal interact_request(body : Node2D)


signal enter_scene(param : Dictionary)


signal camera_shake(strength : Vector2, during : float)

# signal health_change(val : int)
# signal stamina_change(val : int)

signal player_teleport_request(teleport_position : Vector2)
signal stamina_upper_limit_increased(val : int)
signal health_upper_limit_increased(val : int)
signal player_die()


# ==============================
# --- 新增：摄像机区域专属信号 ---
# ==============================
signal camera_area_entered(area_node : Node2D)
signal camera_area_exited(area_node : Node2D)


# ==============================
# --- 新增：关卡流转专属信号 ---
# ==============================
# 传入 true 表示开局第一次加载，false 表示游戏中途切层
signal level_transition_started(is_initial_start: bool)

signal ready_to_change_scene()      # UI通知：黑屏已拉好，主菜单去切场景，或者world开始初次建图
signal execute_map_rebuild()        # UI通知：黑屏已拉好，world开始重建地图
signal map_rebuild_finished()       # world通知UI：地图生成完毕，可以淡出揭幕了

# ==================== 世界掉落物交互 UI 信号 ====================
signal skill_world_brief_requested(skill_data: SkillData, target: Node2D)
signal skill_world_brief_closed()

signal rune_world_brief_requested(rune_data: RuneData, target: Node2D)



# 信号符文
signal emit_rune_signalA()