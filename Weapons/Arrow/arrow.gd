class_name ArrowWeapon
extends BaseWeapon

@export var speed: float = 400.0
@export var lifetime: float = 1.5

var direction: Vector2 = Vector2.RIGHT

func _init():
	weapon_type = BaseWeapon.WeaponType.RANGED

func _ready():
	super._ready()
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _on_stats_changed() -> void:
	var total_size = Global.size_multiplier * (1.0 + Global.items.get("magic_yeast", 0) * 0.05)
	scale = Vector2.ONE * total_size

func _physics_process(delta):
	var bonus_speed = 1.0 + (Global.items.get("light_feather", 0) * 0.05)
	position += direction * speed * Global.projectile_speed_multiplier * bonus_speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		var total_knockback = Global.knockback_multiplier * (1.0 + Global.items.get("boxing_glove", 0) * 0.05)
		var kb := global_position.direction_to(body.global_position) * 300.0 * total_knockback
		var is_crit := Global.roll_crit()
		var dmg := get_total_damage(is_crit)
		body.take_damage(dmg, kb, is_crit)
		queue_free()
	elif body.is_in_group("obstaculos"):
		queue_free()
