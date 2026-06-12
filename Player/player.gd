extends CharacterBody2D

@export var speed = 300.0
@export var health = 100.0

const KNOCKBACK_STRENGTH: float = 450.0
const KNOCKBACK_FRICTION: float = 1800.0
const IFRAMES_DURATION: float = 0.5

var is_invulnerable: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var max_health: float = 100.0

# Dash
var dashes_available: int = 1
var is_dashing: bool = false
var dash_velocity: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var current_dash_cooldown: float = 0.0
const DASH_DURATION: float = 0.2
const DASH_SPEED_MULTIPLIER: float = 3.0
const DASH_COOLDOWN: float = 1.0

@onready var camera = $Camera2D
@onready var anim_body = $Sprite
@onready var anim_shadow = $ShadowSprite
@onready var health_bar = $HealthBar

const ZOOM_MIN = Vector2(0.3, 0.3) # Zoom de alejamiento máximo
const ZOOM_MAX = Vector2(2.5, 2.5) # Zoom de acercamiento máximo
const ZOOM_SPEED = Vector2(0.1, 0.1) # Velocidad del zoom
const CAMERA_SHAKE_INTENSITY: float = 6.0
const CAMERA_SHAKE_DURATION: float = 0.05
const CAMERA_SHAKE_ITERATIONS: int = 5


func _ready():
	Global.stats_changed.connect(_on_stats_changed)
	_on_stats_changed()

func _on_stats_changed():
	var new_max_health = 100.0 + (Global.items.get("dirty_bandage", 0) * 10.0)
	if new_max_health > max_health:
		health += (new_max_health - max_health)
	max_health = new_max_health
	health_bar.max_value = max_health
	health_bar.value = health

func _physics_process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if not is_dashing:
		if Input.is_action_just_pressed("ui_select") and dashes_available > 0 and direction != Vector2.ZERO:
			is_dashing = true
			dashes_available -= 1
			dash_timer = DASH_DURATION
			
			var jump_dist = Global.jump_distance * (1.0 + Global.items.get("rusty_spring", 0) * 0.10)
			dash_velocity = direction * speed * DASH_SPEED_MULTIPLIER * jump_dist
		else:
			var speed_bonus = 1.0 + (Global.items.get("light_boots", 0) * 0.10)
			var current_speed = speed * (0.95 if Global.items.has("lead_boots") else 1.0) * speed_bonus
			velocity = direction * current_speed + knockback_velocity
	else:
		velocity = dash_velocity
		dash_timer -= _delta
		if dash_timer <= 0:
			is_dashing = false
			velocity = Vector2.ZERO

	var max_dashes = Global.jump_count + (1 if Global.items.has("portable_battery") else 0)
	if dashes_available < max_dashes:
		current_dash_cooldown += _delta
		if current_dash_cooldown >= DASH_COOLDOWN:
			dashes_available += 1
			current_dash_cooldown -= DASH_COOLDOWN

	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * _delta)
	move_and_slide()
	
	var anim_name = "idle"
	if velocity.length() > 0:
		anim_name = "run"
	
	anim_body.play(anim_name)
	anim_shadow.play(anim_name) 
	
	anim_body.flip_h = velocity.x < 0

	var total_regen = Global.hp_regen + (Global.items.get("copper_amulet", 0) * 0.2)
	if total_regen > 0 and health > 0 and health < max_health and not Global.items.has("blood_pact"):
		health = min(health + (total_regen * _delta), max_health)
		health_bar.value = health

func find_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest_dist = INF
	var closest_enemy = null	
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_enemy = enemy
	return closest_enemy

func heal(amount: float):
	if health > 0 and health < max_health:
		health = min(health + amount, max_health)
		health_bar.value = health
	
func take_damage(amount: float, source_node: Node2D = null):
	if is_invulnerable:
		return
		
	if Global.items.has("broken_mirror"):
		var dodge_chance = 0.15 * (2.0 if Global.items.has("overpowered_lamp") else 1.0)
		if randf() < dodge_chance:
			return # Esquivó el ataque

	var damage_reduction = min(0.9, Global.items.get("wooden_kneepad", 0) * 0.02)
	amount = amount * (1.0 - damage_reduction)

	health -= amount
	health_bar.value = health
	health_bar.visible = true
	AudioManager.play_sfx("player_hit")

	var src_pos = source_node.global_position if source_node else Vector2.ZERO

	if src_pos != Vector2.ZERO and not Global.items.has("lead_boots"):
		knockback_velocity = src_pos.direction_to(global_position) * KNOCKBACK_STRENGTH
		
	var thorns_mult = Global.items.get("thorn_armor", 0) * 0.50
	if thorns_mult > 0 and source_node and source_node.has_method("take_damage"):
		source_node.take_damage(amount * thorns_mult, Vector2.ZERO, false)

	if health <= 0:
		die()
		return

	is_invulnerable = true
	_flicker()
	_shake_camera()
	
	var total_iframes = IFRAMES_DURATION * (1.0 + Global.items.get("pocket_watch", 0) * 0.15)
	await get_tree().create_timer(total_iframes).timeout
	if is_instance_valid(self):
		is_invulnerable = false
		modulate = Color.WHITE

func _shake_camera(intensity: float = CAMERA_SHAKE_INTENSITY, duration_step: float = CAMERA_SHAKE_DURATION, iterations: int = CAMERA_SHAKE_ITERATIONS) -> void:
	var tween := create_tween()
	for i in range(iterations):
		tween.tween_property(camera, "offset",
			Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), duration_step)
	tween.tween_property(camera, "offset", Vector2.ZERO, duration_step)

func _flicker() -> void:
	modulate = Color(1, 0.2, 0.2)
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	for _i in range(5):
		tween.tween_property(self, "modulate:a", 0.2, 0.05)
		tween.tween_property(self, "modulate:a", 1.0, 0.05)

func die():
	set_physics_process(false)
	is_invulnerable = true
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 1.0)
	await tween.finished
	
	var screen = get_tree().get_first_node_in_group("game_over_screen")
	if screen:
		screen.show_game_over(Global.get_time_elapsed())
	else:
		get_tree().reload_current_scene()
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom += ZOOM_SPEED
			if camera.zoom > ZOOM_MAX:
				camera.zoom = ZOOM_MAX
				
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom -= ZOOM_SPEED
			if camera.zoom < ZOOM_MIN:
				camera.zoom = ZOOM_MIN
