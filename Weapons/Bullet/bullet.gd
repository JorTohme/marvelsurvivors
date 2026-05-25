class_name BulletWeapon
extends BaseWeapon

@export var speed: float = 600.0
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
	scale = Vector2.ONE * Global.size_multiplier

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		var kb := global_position.direction_to(body.global_position) * 300.0 * Global.knockback_multiplier
		var is_crit := Global.roll_crit()
		var dmg := base_damage * Global.damage_multiplier * (2.0 if is_crit else 1.0)
		body.take_damage(dmg, kb, is_crit)
		queue_free()
