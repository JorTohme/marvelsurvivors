class_name BulletWeapon
extends BaseWeapon

@export var speed: float = 450.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _init():
	weapon_type = BaseWeapon.WeaponType.RANGED
	spawn_in_line = true
	line_spacing_delay = 0.15

var _base_scale: Vector2

func _ready():
	_base_scale = scale
	super._ready()
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _on_stats_changed() -> void:
	if _base_scale == Vector2.ZERO: return
	var total_size = Global.size_multiplier * (1.0 + Global.items.get("magic_yeast", 0) * 0.05)
	scale = _base_scale * total_size

func _physics_process(delta):
	var bonus_speed = 1.0 + (Global.items.get("light_feather", 0) * 0.05)
	position += direction * speed * Global.projectile_speed_multiplier * bonus_speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		var total_knockback = Global.knockback_multiplier * (1.0 + Global.items.get("boxing_glove", 0) * 0.05)
		var kb := global_position.direction_to(body.global_position) * 50.0 * total_knockback
		var is_crit := Global.roll_crit()
		var dmg := get_total_damage(is_crit)
		if body.has_method("take_damage"):
			body.take_damage(dmg, kb, is_crit)
		
		# Probabilidad de rebotar del 30%
		if randf() < 0.3:
			if not _bounce_to_next_enemy(body):
				queue_free()
		else:
			queue_free()
	elif body.is_in_group("obstaculos"):
		queue_free()

func _bounce_to_next_enemy(exclude_enemy: Node2D) -> bool:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest_enemy = null
	var closest_dist = 999999.0
	
	for enemy in enemies:
		if enemy == exclude_enemy or not is_instance_valid(enemy):
			continue
		if "is_dying" in enemy and enemy.is_dying:
			continue
			
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist and dist < 600.0:
			closest_dist = dist
			closest_enemy = enemy
			
	if closest_enemy != null:
		direction = global_position.direction_to(closest_enemy.global_position)
		rotation = direction.angle()
		return true
		
	return false
