extends Area2D

var xp_amount: int = 5

@onready var collision = $CollisionShape2D

var is_collected = false
var is_chasing = false
var target_body = null
var speed = 0.0

func _ready():
	randomize_gem()
	animate_spawn()

func randomize_gem():
	var roll = randf()
	
	if roll < 0.75:
		xp_amount = 5
		modulate = Color.CYAN
	elif roll < 0.90:
		xp_amount = 8
		modulate = Color.VIOLET
	else:
		xp_amount = 10
		modulate = Color.GOLD

func animate_spawn():
	collision.set_deferred("disabled", true)
	
	var random_offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	var target_pos = global_position + random_offset
	
	scale = Vector2(0.1, 0.1)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "global_position", target_pos, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	rotation_degrees = randf_range(-180, 180)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	get_tree().create_timer(0.3).timeout.connect(func(): collision.set_deferred("disabled", false))

func _physics_process(delta):
	if is_chasing and is_instance_valid(target_body):
		var direction = global_position.direction_to(target_body.global_position)
		speed += 1500 * delta
		
		global_position += direction * speed * delta
		
		if global_position.distance_to(target_body.global_position) < 15:
			finish_collection()

func _on_body_entered(body):
	if is_collected: return
	if collision.disabled: return
	
	if body.is_in_group("player"):
		start_collection_animation(body)

func start_collection_animation(player):
	is_collected = true
	target_body = player
	
	collision.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	
	tween.tween_callback(func(): is_chasing = true)

func finish_collection():
	if Global.has_method("add_xp"):
		Global.add_xp(xp_amount)
	queue_free()
