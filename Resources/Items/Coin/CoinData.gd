extends ItemData
class_name CoinData

@export var coin_amount: int = 0

func apply_effect(player: Node2D) -> bool:
    if player as Player:
        if player.stats_component:
            return player.stats_component.add_coin(coin_amount)
    return false