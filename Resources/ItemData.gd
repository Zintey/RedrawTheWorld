class_name ItemData extends Resource

@export var item_name: String
@export var icon: Texture2D
@export_multiline var description: String

# 策略模式通用接口：物品被购买/拾取时触发。成功返回 true，失败返回 false
func apply_effect(player: Node2D) -> bool:
	return false