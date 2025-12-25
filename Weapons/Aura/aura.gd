extends Area2D

@export var damage: float = 5.0           # Daño por golpe
@export var diameter: float = 500.0       # Tamaño total en píxeles
@export var attack_cooldown: float = 0.5  # Tiempo entre golpes (segundos)

var aura_color_fill = Color(0.283, 0.661, 0.887, 0.2)
var aura_color_border = Color(0.2, 0.584, 0.839, 1.0)

var is_aura = true
var is_melee = false

func _ready():
	$Timer.wait_time = attack_cooldown
	$Timer.timeout.connect(_on_timer_timeout)
	
	update_aura_size()

func _process(delta):
	rotation += 0.5 * delta

func _draw():
	var radius = diameter / 2.0
	draw_circle(Vector2.ZERO, radius, aura_color_fill)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, aura_color_border, 2.0)

func update_aura_size():
	var radius = diameter / 2.0
	
	if $CollisionShape2D.shape is CircleShape2D:
		$CollisionShape2D.shape.radius = radius
	else:
		var new_shape = CircleShape2D.new()
		new_shape.radius = radius
		$CollisionShape2D.shape = new_shape
	
	queue_redraw()

func _on_timer_timeout():
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage, body.global_position)

func level_up_aura():
	damage += 2.0             # +2 Daño
	diameter += 30.0          # +30 Pixeles de rango
	attack_cooldown *= 0.9    # 10% más rápido cada nivel
	
	$Timer.wait_time = attack_cooldown
	
	update_aura_size()
