extends CharacterBody2D

@onready var anim_body = $EnemyBodySprite
@onready var anim_shadow = $ShadowSprite
@onready var health_bar = $HealthBar
@onready var body_sprite = $EnemyBodySprite
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var speed = 100.0
@export var health = 30.0
@export var damage_interval = 1.0

var player_ref = null
var is_invulnerable: bool = true
var is_dying: bool = false
var is_elite: bool = false

var base_color = Color.WHITE 

var knockback_vector = Vector2.ZERO
var knockback_resistance = 10.0
var damage = 10

var player_touching = null
var time_until_next_damage = 0.0

var gem_scene = preload("res://ExpGem/exp_gem.tscn")

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	
	modulate.a = 0.5 
	
	await get_tree().create_timer(0.5).timeout
	
	is_invulnerable = false
	modulate.a = 1.0
	
	health_bar.max_value = health
	health_bar.value = health
	health_bar.visible = false

func _physics_process(delta):
	if player_ref && !is_invulnerable:
		nav_agent.target_position = player_ref.global_position
		
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		
		velocity = direction * speed
		velocity += knockback_vector
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, knockback_resistance)
		
		move_and_slide()
		
		anim_body.play("run")
		anim_shadow.play("run")
		
		anim_body.flip_h = direction.x < 0
	
	if player_touching:
		var dist = global_position.distance_to(player_touching.global_position)
		if dist > 60.0:
			player_touching = null
		else:
			time_until_next_damage -= delta
			if time_until_next_damage <= 0:
				attack_player()
				time_until_next_damage = damage_interval

func make_elite():
	is_elite = true
	scale = Vector2(1.5, 1.5)
	health *= 5
	modulate = base_color
	knockback_resistance = 100.0

func take_damage(amount, source_position = null):
	if is_invulnerable || is_dying:
		return
	
	health -= amount
	health_bar.value = health
	health_bar.visible = true
	
	if source_position != null:
		var knockback_direction = source_position.direction_to(global_position)
		knockback_vector = knockback_direction * 300
	
	await get_tree().create_timer(0.1).timeout
	
	if health <= 0:
		die()

func die():
	if is_dying: return
	is_dying = true
	
	if is_elite:
		for i in range(5):
			spawn_gem()
	else:
		spawn_gem()
	
	queue_free()

func spawn_gem():
	var new_gem = gem_scene.instantiate()
	var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	new_gem.global_position = global_position + offset
	get_tree().current_scene.call_deferred("add_child", new_gem)

func attack_player():
	if player_touching and player_touching.has_method("take_damage"):
		player_touching.take_damage(damage)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_touching = body
		attack_player()
		time_until_next_damage = damage_interval

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body == player_touching:
		player_touching = null
