extends Node2D

@export_category("Configuración Principal")
@export var weapon_scene: PackedScene
@export var cooldown: float = 1.0

@export_category("Comportamiento")
@export var projectile_count: int = 1

@export_group("Ángulos y Dispersión")
@export var manual_arc_degrees: float = 0.0
@export var spread_degrees: float = 20.0

var _weapon_type: BaseWeapon.WeaponType = BaseWeapon.WeaponType.RANGED
var _aura_instance: BaseWeapon = null

@onready var timer = $Timer
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	if not weapon_scene:
		set_process(false)
		return

	_detect_weapon_type()

	if _weapon_type == BaseWeapon.WeaponType.AURA:
		_spawn_aura()
		timer.stop()
	else:
		timer.wait_time = cooldown
		timer.timeout.connect(_on_timer_timeout)
		timer.start()

func _detect_weapon_type():
	var temp = weapon_scene.instantiate()
	if temp is BaseWeapon:
		_weapon_type = temp.weapon_type
	temp.queue_free()

func _spawn_aura():
	if _aura_instance != null:
		return
	_aura_instance = weapon_scene.instantiate()
	add_child(_aura_instance)
	_aura_instance.position = Vector2.ZERO

func level_up():
	if _weapon_type == BaseWeapon.WeaponType.AURA:
		if _aura_instance and is_instance_valid(_aura_instance):
			_aura_instance.level_up()
	else:
		cooldown = max(0.3, cooldown * 0.85)
		timer.wait_time = cooldown
		projectile_count = min(projectile_count + 1, 5)

func _on_timer_timeout():
	if not player:
		return
	var base_direction = _get_fire_direction()
	_spawn_projectiles(base_direction)

func _get_fire_direction() -> Vector2:
	if _weapon_type == BaseWeapon.WeaponType.MELEE:
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_dir.length() > 0:
			return input_dir.normalized()
		if player.velocity.length() > 0:
			return player.velocity.normalized()
		var sprite = player.get_node_or_null("AnimatedSprite2D")
		if sprite and sprite.flip_h:
			return Vector2.LEFT
		return Vector2.RIGHT
	else:
		var target = player.find_nearest_enemy()
		if target:
			return player.global_position.direction_to(target.global_position)
		if player.velocity.length() > 0:
			return player.velocity.normalized()
		return Vector2.RIGHT

func _spawn_projectiles(base_direction: Vector2):
	var count := projectile_count + Global.quantity_bonus
	var arc_rad: float = _calculate_arc(count)
	var angle_step: float = 0.0
	if count > 1:
		var divisor: int = count if abs(rad_to_deg(arc_rad)) >= 360 else (count - 1)
		angle_step = arc_rad / divisor
	var start_angle: float = -arc_rad / 2.0

	for i in range(count):
		var projectile: BaseWeapon = weapon_scene.instantiate()
		var angle_offset: float = start_angle + (angle_step * i) if count > 1 else 0.0
		var final_direction: Vector2 = base_direction.rotated(angle_offset)

		if _weapon_type == BaseWeapon.WeaponType.MELEE:
			player.add_child(projectile)
			projectile.relative_rotation = angle_offset
		else:
			get_tree().current_scene.add_child(projectile)
			projectile.global_position = player.global_position

		if "direction" in projectile:
			projectile.direction = final_direction
		projectile.rotation = final_direction.angle()

func _calculate_arc(count: int) -> float:
	var deg := manual_arc_degrees
	if spread_degrees > 0 and count > 1:
		deg = spread_degrees * (count - 1)
		deg = min(deg, 360.0)
	return deg_to_rad(deg)
