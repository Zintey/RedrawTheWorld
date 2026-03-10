# EdenState.gd
# Eden 状态专用的中间基类。
# 相比 EnemyState，只是把 agent 的类型收窄成 Eden，
# 这样具体状态里写 agent.is_mode_1() / agent.fire_attack_fx() 时有类型提示，不会报错。
#
# 注意：这个文件只有 4 行实质内容，非常轻量，
# 存在的唯一理由是让 GDScript 的静态类型检查正常工作。

extends EnemyState
class_name EdenState

# 覆盖 agent 类型为 Eden，其余一切继承自 EnemyState
@export var agent: Eden
