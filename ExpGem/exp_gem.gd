extends Area2D

var xp_amount: int = 5 

@onready var collision = $CollisionShape2D

var is_collected = false
var is_chasing = false
var target_body = null
var speed = 0.0

func _ready():
	randomize_gem()

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


func _physics_process(delta):
	if is_chasing and is_instance_valid(target_body):
		var direction = global_position.direction_to(target_body.global_position)
		speed += 1500 * delta 
		
		global_position += direction * speed * delta
		
		if global_position.distance_to(target_body.global_position) < 15:
			finish_collection()

func _on_body_entered(body):
	if is_collected: return
	
	if body.is_in_group("player"):
		start_collection_animation(body)

func start_collection_animation(player):
	is_collected = true
	target_body = player
	
	collision.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(0, -30), 0.2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_callback(func(): is_chasing = true)

func finish_collection():
	Global.add_xp(xp_amount)
	queue_free()
