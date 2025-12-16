extends Area2D

@export var xp_amount: int = 10
@onready var collision = $CollisionShape2D

var is_collected = false

func _on_body_entered(body):
	if is_collected: return
	
	if body.is_in_group("player"):
		start_collection_animation(body)

func start_collection_animation(target_player):
	is_collected = true
	collision.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(0, -30), 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "global_position", target_player.global_position, 0.2)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_callback(finish_collection)

func finish_collection():
	Global.add_xp(xp_amount)
	queue_free()
