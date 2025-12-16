extends Area2D

var relative_rotation: float = 0.0 
var is_melee: bool = true

var weapon_damage: float = 5.0

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(0.7).timeout
	queue_free()

func _physics_process(_delta):
	if is_melee:
		var player = get_parent()
		if player is Node2D and player.velocity.length() > 0:
			rotation = player.velocity.angle() + relative_rotation

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(weapon_damage, global_position)
		else:
			body.queue_free()
