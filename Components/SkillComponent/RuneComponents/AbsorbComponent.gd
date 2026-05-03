class_name AbsorbComponent extends RuneComponent

var absorb_amount: int = 0

func _ready():
    super()
    core.on_hit.connect(_on_hit)

func _on_hit(target: Node2D):
    if target is HurtBox:
        if is_instance_valid(core.caster) and core.caster.get("stats_component"):
            core.caster.stats_component.recover_stamina(absorb_amount)