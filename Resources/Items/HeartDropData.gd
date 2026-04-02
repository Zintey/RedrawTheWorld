extends ItemData
class_name HeartDropData

@export var recover_hp_amount: float = 1

func apply_effect(player: Node2D) -> bool:
    if player as Player:
        if player.health_component:
            return player.health_component.recover_hp(recover_hp_amount)
    return false