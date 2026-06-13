extends Area2D

var damage = 15.0
var delay = 0.5
var radius = 65.0

@onready var indicator = $Indicator
@onready var collision = $CollisionShape2D

func _ready():
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	
	indicator.color = Color(0.8, 0.1, 0.8, 0.2) # Violeta transparente
	indicator.polygon = _get_circle_polygon(radius)
	
	var tween = create_tween()
	tween.tween_property(indicator, "color:a", 0.7, delay)
	await get_tree().create_timer(delay).timeout
	explode()

func explode():
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(damage, self)
			
	var p = CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 0.95
	p.lifetime = 0.4
	p.amount = 40
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = radius
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 80.0
	p.scale_amount_min = 4.0
	p.scale_amount_max = 8.0
	p.color = Color(0.9, 0.2, 0.9)
	get_tree().current_scene.add_child(p)
	p.global_position = global_position
	p.emitting = true
	get_tree().create_timer(0.5).timeout.connect(p.queue_free)
	
	AudioManager.play_sfx("hit") # Reutilizamos el sonido hit o algo similar
	queue_free()

func _get_circle_polygon(r: float) -> PackedVector2Array:
	var pts = PackedVector2Array()
	var sides = 32
	for i in range(sides):
		var angle = i * TAU / sides
		pts.append(Vector2(cos(angle), sin(angle)) * r)
	return pts
