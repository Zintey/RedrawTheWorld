extends InteractiveItem


@export var rune_list : Array[RuneData]
@export var skill_list : Array[SkillData]
# @export var icon : Texture2D
func _ready():
	super()
	if rune_list.size() >= 1:
		match rune_list[0].type:
			RuneData.RuneType.TRIGGER:
				item_sprite.modulate = Color.YELLOW
			RuneData.RuneType.CORE:
				item_sprite.modulate = Color.PURPLE
			RuneData.RuneType.MODIFIER:
				item_sprite.modulate = Color.GRAY
			

func take_interact(body : Node2D):

	body = body as Player
	if body:
		body.add_runes(rune_list)
		body.add_skills(skill_list)

	queue_free()
