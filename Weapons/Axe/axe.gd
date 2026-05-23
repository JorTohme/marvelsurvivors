class_name AxeWeapon
extends BaseWeapon

var relative_rotation: float = 0.0

func _init():
	weapon_type = BaseWeapon.WeaponType.MELEE

func _ready():
	super._ready()
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(0.7).timeout
	if is_instance_valid(self):
		queue_free()

func _on_stats_changed() -> void:
	scale = Vector2.ONE * Global.size_multiplier

func _physics_process(_delta):
	var player = get_parent()
	if player is CharacterBody2D and player.velocity.length() > 0:
		rotation = player.velocity.angle() + relative_rotation

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		var kb := global_position.direction_to(body.global_position) * 300.0 * Global.knockback_multiplier
		body.take_damage(base_damage * Global.damage_multiplier, kb)
