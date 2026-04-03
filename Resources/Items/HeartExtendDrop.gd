extends ItemData
class_name HeartExtendDrop

@export var extend_hp_amount = 1.0

func apply_effect(player: Node2D) -> bool:
    if player is Player:
        if player.health_component:
            return player.health_component.extend_hp(extend_hp_amount)
    return false
