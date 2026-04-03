extends ItemData
class_name StaminaExtendDrop

@export var extend_stamina_amount = 1.0

func apply_effect(player: Node2D) -> bool:
	if player is Player:
		if player.stats_component:
			return player.stats_component.extend_stamina(extend_stamina_amount)
	return false
