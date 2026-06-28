class_name AxeWeapon
extends BaseWeapon

var relative_rotation: float = 0.0

func _init():
	weapon_type = BaseWeapon.WeaponType.MELEE

func _ready():
	super._ready()
	body_entered.connect(_on_body_entered)
	$Sprite2D.texture = load("res://Assets/Items/axe.png")
	$Sprite2D.scale = Vector2(0.1, 0.1) # Ajustamos la escala para que no se vea deformado
	await get_tree().create_timer(0.7).timeout
	if is_instance_valid(self):
		queue_free()

func _on_stats_changed() -> void:
	var total_size = Global.size_multiplier * (1.0 + Global.items.get("magic_yeast", 0) * 0.05)
	scale = Vector2.ONE * total_size

func _physics_process(_delta):
	var player = get_parent()
	if player is CharacterBody2D and player.velocity.length() > 0:
		rotation = player.velocity.angle() + relative_rotation
		
	# Rotación sobre sí misma
	$Sprite2D.rotation += 20.0 * _delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		var total_knockback: float = Global.knockback_multiplier * (1.0 + float(Global.items.get("boxing_glove", 0)) * 0.05)
		var kb: Vector2 = global_position.direction_to(body.global_position) * 300.0 * total_knockback
		var is_crit := Global.roll_crit()
		var dmg := get_total_damage(is_crit)
		body.take_damage(dmg, kb, is_crit)
