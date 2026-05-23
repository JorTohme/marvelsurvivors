class_name AuraWeapon
extends BaseWeapon

@export var diameter: float = 500.0
@export var attack_cooldown: float = 0.5

var aura_color_fill := Color(0.283, 0.661, 0.887, 0.2)
var aura_color_border := Color(0.2, 0.584, 0.839, 1.0)

func _init():
	weapon_type = BaseWeapon.WeaponType.AURA

func _ready():
	$Timer.wait_time = attack_cooldown
	$Timer.timeout.connect(_on_timer_timeout)
	_update_size()

func _process(delta):
	rotation += 0.5 * delta

func _draw():
	var radius = diameter / 2.0
	draw_circle(Vector2.ZERO, radius, aura_color_fill)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, aura_color_border, 2.0)

func _update_size():
	var radius = diameter / 2.0
	var shape = $CollisionShape2D.shape
	if shape is CircleShape2D:
		shape.radius = radius
	else:
		var new_shape = CircleShape2D.new()
		new_shape.radius = radius
		$CollisionShape2D.shape = new_shape
	queue_redraw()

func _on_timer_timeout():
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(base_damage, body.global_position)

func level_up():
	base_damage += 2.0
	diameter += 30.0
	attack_cooldown = max(0.1, attack_cooldown * 0.9)
	$Timer.wait_time = attack_cooldown
	_update_size()
