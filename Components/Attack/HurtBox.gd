extends Area2D
class_name HurtBox

signal took_damage(amount: float, knockback_force : Vector2)

@export var health_component: HealthComponent
@export var is_invincible: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	# 检查自己有没有绑好血量组件
	# var owner_name = owner.name if owner else "未知节点"
	# if health_component == null:
		# printerr("⚠️ [HurtBox 警告] ", owner_name, " 的 HurtBox 没有绑定 HealthComponent！它挨打不会扣血！")
	# else:
		# print("✅ [HurtBox 正常] ", owner_name, " 准备就绪。")

func _on_area_entered(area: Area2D) -> void:
	# var owner_name = owner.name if owner else "未知节点"
	# print("👉 [碰撞测试] ", owner_name, " 的 HurtBox 被 ", area.name, " 碰到了！")
	
	if is_invincible:
		# print("   -> 拦截：", owner_name, " 正处于无敌/闪烁帧。")
		return
		
	if area is HitBox:
		# print("   -> 成功！识别为 HitBox，造成伤害：", area.damage)
		take_damage(area.damage, area.knockback_force * (global_position - area.global_position))
	# else:
		# print("   -> 失败：撞上来的 ", area.name, " 不是 HitBox，它的实际类型/类名是：", area.get_class())

func take_damage(amount: float, knockback_force : Vector2) -> void:
	took_damage.emit(amount, knockback_force)
	if health_component:
		health_component.decrease_hp(amount)
		if collision_layer == (1 << 4):
			Engine.time_scale = 0.05
			print("frezze time")
			AudioManager.play_sfx(preload("uid://b5cjlus3fk7wm"))
			get_tree().create_timer(0.08, true, false, true).timeout.connect(func () : Engine.time_scale = 1.0)
		