extends CharacterBody2D

@export var speed = 300.0
@export var health = 100.0

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
	velocity = direction * speed
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
	
func take_damage(amount):
	health -= amount

	health_bar.value = health
	health_bar.visible = true
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
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
