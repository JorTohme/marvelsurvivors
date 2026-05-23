extends CharacterBody2D

@export var speed = 300.0
@export var health = 100.0

const KNOCKBACK_STRENGTH: float = 450.0
const KNOCKBACK_FRICTION: float = 1800.0
const IFRAMES_DURATION: float = 0.5

var is_invulnerable: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

@onready var camera = $Camera2D
@onready var anim_body = $Sprite
@onready var anim_shadow = $ShadowSprite
@onready var health_bar = $HealthBar

const zoom_min = Vector2(0.3, 0.3) # zoom out
const zoom_max = Vector2(2.5, 2.5) # zoom in
const zoom_speed = Vector2(0.1, 0.1) # Qué tan rápido cambia


func _ready():
	health_bar.max_value = health
	health_bar.value = health
	health_bar.visible = false

func _physics_process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed + knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * _delta)
	move_and_slide()
	
	var anim_name = "idle"
	if velocity.length() > 0:
		anim_name = "run"
	
	anim_body.play(anim_name)
	anim_shadow.play(anim_name) 
	
	anim_body.flip_h = velocity.x < 0

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
	
func take_damage(amount: float, source_position: Vector2 = Vector2.ZERO):
	if is_invulnerable:
		return

	health -= amount
	health_bar.value = health
	health_bar.visible = true

	if source_position != Vector2.ZERO:
		knockback_velocity = source_position.direction_to(global_position) * KNOCKBACK_STRENGTH

	if health <= 0:
		die()
		return

	is_invulnerable = true
	_flicker()
	await get_tree().create_timer(IFRAMES_DURATION).timeout
	if is_instance_valid(self):
		is_invulnerable = false
		modulate = Color.WHITE

func _flicker() -> void:
	modulate = Color(1, 0.2, 0.2)
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	for _i in range(5):
		tween.tween_property(self, "modulate:a", 0.2, 0.05)
		tween.tween_property(self, "modulate:a", 1.0, 0.05)

func die():
	var screen = get_tree().get_first_node_in_group("game_over_screen")
	if screen:
		screen.show_game_over(Global.get_time_elapsed())
	else:
		get_tree().reload_current_scene()
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom += zoom_speed
			if camera.zoom > zoom_max:
				camera.zoom = zoom_max
				
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom -= zoom_speed
			if camera.zoom < zoom_min:
				camera.zoom = zoom_min
