extends Marker2D
class_name DoorSlot

@export_group("Grid Configuration")
# 这个门在房间内部的哪个格子上？（例如 2x1 房间的右半边就是 (1, 0)）
@export var local_grid_pos: Vector2i = Vector2i.ZERO

# 门的方向：只能填 "U", "D", "L", "R"
@export_enum("U", "D", "L", "R") var direction: String = "U"