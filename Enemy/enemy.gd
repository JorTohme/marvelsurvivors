extends CharacterBody2D
@onready var anim_body = $Sprite
@onready var anim_shadow = $ShadowSprite

@export var speed = 150.0
@export var health = 10.0

@onready var health_bar = $HealthBar

var player_ref = null
var is_invulnerable: bool = true
var is_dying: bool = false

var knockback_vector = Vector2.ZERO
var knockback_resistance = 10.0

var damage = 10

var gem_scene = preload("res://exp_gem.tscn")

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	# EFECTO VISUAL: El enemigo nace medio transparente
	modulate.a = 0.5 
	await get_tree().create_timer(0.5).timeout
	is_invulnerable = false
	modulate.a = 1.0
	
	health_bar.max_value = health
	health_bar.value = health
	health_bar.visible = false

func _physics_process(_delta):
	if player_ref && !is_invulnerable:
		var direction = global_position.direction_to(player_ref.global_position)
		velocity = direction * speed
		velocity += knockback_vector
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, knockback_resistance)
		
		move_and_slide()
		
		anim_body.play("run")
		anim_shadow.play("run") 
		
		anim_body.flip_h = velocity.x < 0

func take_damage(amount, source_position = null):
	if is_invulnerable || is_dying:
		return
	
	health -= amount
	health_bar.value = health
	health_bar.visible = true
	
	if source_position != null:
		var knockback_direction = source_position.direction_to(global_position)
		knockback_vector = knockback_direction * 300
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()
	
func die():
	if is_dying: return
	is_dying = true
	var new_gem = gem_scene.instantiate()
	var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	new_gem.global_position = global_position + offset
	get_tree().current_scene.call_deferred("add_child", new_gem)
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(10)
