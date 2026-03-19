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