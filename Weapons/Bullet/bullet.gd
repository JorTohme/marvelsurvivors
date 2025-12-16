extends Area2D

var speed = 400
var direction = Vector2.RIGHT

var weapon_damage: float = 5.0
var is_melee: bool = false

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(weapon_damage, global_position)
		else:
			body.queue_free()
		queue_free()
