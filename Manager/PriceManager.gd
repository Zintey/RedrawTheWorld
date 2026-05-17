extends Node

const BASE_PRICES = {
	"RUNE_TRIGGER": 30,
	"RUNE_CORE": 80,
	"RUNE_MODIFIER": 50,
	"SKILL_TEMPLATE": 120,
	"FALLBACK": 15 # 兜底物品（如小血瓶）的价格
}

func get_item_price(item_data: ItemData, depth: int) -> int:
	var base_price = BASE_PRICES["FALLBACK"]
	
	if item_data is RuneData:
		match item_data.type:
			RuneData.RuneType.TRIGGER: base_price = BASE_PRICES["RUNE_TRIGGER"]
			RuneData.RuneType.CORE: base_price = BASE_PRICES["RUNE_CORE"]
			RuneData.RuneType.MODIFIER: base_price = BASE_PRICES["RUNE_MODIFIER"]
	elif item_data is SkillData:
		base_price = BASE_PRICES["SKILL_TEMPLATE"]
		
	# 通胀计算：每下一层贵 20%
	var multiplier = 1.0 + (depth - 1) * 0.2
	return int(base_price * multiplier)
