extends CharacterBody2D

@onready var anim_body = $EnemyBodySprite
@onready var anim_shadow = $ShadowSprite
@onready var health_bar = $HealthBar
@onready var body_sprite = $EnemyBodySprite
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var speed = 100.0
@export var health = 30.0
@export var damage_interval = 1.0

const BASE_ELITE_HEALTH: float = 10.0
const HEALTH_PER_MINUTE_ELITE: float = 15.0
const BASE_RUNNER_HEALTH: float = 5.0
const HEALTH_PER_MINUTE_RUNNER: float = 5.0
const BASE_HEALTH: float = 10.0
const HEALTH_PER_MINUTE: float = 10.0
const INVULNERABLE_TIME: float = 0.5
const TOUCH_DISTANCE: float = 60.0
const DMG_NUM_Y_OFFSET: float = -50.0
const GEM_OFFSET_RANGE: float = 30.0

var player_ref = null
var is_invulnerable: bool = true
var is_dying: bool = false
var is_elite: bool = false
var is_runner: bool = false

var base_color = Color.WHITE 

var knockback_vector = Vector2.ZERO
var knockback_resistance = 10.0
var damage = 10

var player_touching = null
var time_until_next_damage = 0.0
var nav_timer = 0.0

var gem_scene = preload("res://ExpGem/exp_gem.tscn")
var _dmg_num_script = preload("res://HUD/damage_number.gd")

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	nav_timer = randf_range(0.0, 0.5) # Desincronizamos las actualizaciones iniciales
	
	var minute = Global.get_current_minute() if Global.has_method("get_current_minute") else 0
	
	if is_elite:
		health = (BASE_ELITE_HEALTH + minute * HEALTH_PER_MINUTE_ELITE) * 5
	elif is_runner:
		health = BASE_RUNNER_HEALTH + (minute * HEALTH_PER_MINUTE_RUNNER)
	else:
		health = BASE_HEALTH + (minute * HEALTH_PER_MINUTE)
		
	modulate.a = 0.5 
	
	await get_tree().create_timer(INVULNERABLE_TIME).timeout
	
	is_invulnerable = false
	modulate.a = 1.0
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.8, 0.2, 0.2)
	health_bar.add_theme_stylebox_override("fill", style)
	
	health_bar.max_value = health
	health_bar.value = health
	health_bar.visible = false

func _physics_process(delta):
	if player_ref && !is_invulnerable:
		nav_timer -= delta
		if nav_timer <= 0:
			nav_agent.target_position = player_ref.global_position
			nav_timer = randf_range(0.3, 0.6) # Recalcula cada 0.3-0.6 segundos
			
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
		if dist > TOUCH_DISTANCE:
			player_touching = null
		else:
			time_until_next_damage -= delta
			if time_until_next_damage <= 0:
				attack_player()
				time_until_next_damage = damage_interval

func make_elite():
	is_elite = true
	scale = Vector2(1.5, 1.5)
	modulate = base_color
	knockback_resistance = 100.0

func make_runner():
	is_runner = true
	scale = Vector2(0.35, 0.35) # Reducimos el tamaño para hacerlo más pequeño y rápido
	speed = 260.0 # Aumentamos la velocidad
	knockback_resistance = 2.0 # Reducimos la resistencia para que salga volando más fácil
	modulate = Color(1.0, 0.6, 0.6) # Color rojizo para destacar visualmente

func take_damage(amount: float, knockback: Vector2 = Vector2.ZERO, is_crit: bool = false, is_static_chain: bool = false):
	if is_invulnerable || is_dying:
		return

	health -= amount
	health_bar.value = health
	health_bar.visible = true
	knockback_vector = knockback
	_spawn_damage_number(amount, is_crit)
	_spawn_hit_particles()
	AudioManager.play_sfx("hit")
	
	if is_crit:
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("_shake_camera"):
			player._shake_camera(4.0, 0.03, 3)

	if not is_static_chain and Global.items.has("static_gloves"):
		var proc_chance = 0.10 * (2.0 if Global.items.has("overpowered_lamp") else 1.0)
		if randf() < proc_chance:
			_trigger_static_chain(amount)

	await get_tree().create_timer(0.1).timeout

	if health <= 0:
		die()

func die():
	if is_dying: return
	is_dying = true
	AudioManager.play_sfx("enemy_die")
	
	if is_elite:
		Global.add_gold(15)
		for i in range(5):
			spawn_gem()
	else:
		Global.add_gold(2)
		spawn_gem()
	
	if randf() < (0.01 * Global.items.get("bat_tooth", 0)):
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("heal"):
			player.heal(1)
	
	queue_free()

func _trigger_static_chain(dmg: float):
	var enemies = get_tree().get_nodes_in_group("enemy")
	var chained = 0
	for e in enemies:
		if e == self or not is_instance_valid(e):
			continue
			
		if "is_dying" in e and not e.is_dying and e.has_method("take_damage"):
			if e.global_position.distance_to(global_position) < 250.0:
				e.take_damage(dmg * 0.5, Vector2.ZERO, false, true)
				chained += 1
				if chained >= 3:
					break

func _spawn_damage_number(amount: float, is_crit: bool = false) -> void:
	var lbl := Label.new()
	lbl.set_script(_dmg_num_script)
	get_tree().current_scene.add_child(lbl)
	lbl.global_position = global_position + Vector2(randf_range(-15.0, 15.0), DMG_NUM_Y_OFFSET)
	lbl.setup(int(amount), is_crit)

func spawn_gem():
	var new_gem = gem_scene.instantiate()
	var offset = Vector2(randf_range(-GEM_OFFSET_RANGE, GEM_OFFSET_RANGE), randf_range(-GEM_OFFSET_RANGE, GEM_OFFSET_RANGE))
	new_gem.global_position = global_position + offset
	get_tree().current_scene.call_deferred("add_child", new_gem)

func _spawn_hit_particles():
	var p = CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 0.8
	p.lifetime = 0.4
	p.amount = 15
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 10.0
	p.spread = 180.0
	p.gravity = Vector2(0, 0)
	p.initial_velocity_min = 50.0
	p.initial_velocity_max = 100.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 4.0
	p.color = Color(0.8, 0.2, 0.2)
	
	get_tree().current_scene.add_child(p)
	p.global_position = global_position
	p.emitting = true
	get_tree().create_timer(0.5).timeout.connect(p.queue_free)

func attack_player():
	if player_touching and player_touching.has_method("take_damage"):
		player_touching.take_damage(damage, self)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_touching = body
		attack_player()
		time_until_next_damage = damage_interval

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body == player_touching:
		player_touching = null
