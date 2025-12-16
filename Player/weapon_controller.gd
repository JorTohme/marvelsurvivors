extends Node2D

@export_category("Configuración")
@export var projectile_scene: PackedScene
@export var cooldown: float = 1.0

@export_category("Disparo")
@export var projectile_count: int = 1

@export_group("Ángulos")
@export var manual_arc_degrees: float = 0.0 
@export var spread_degrees: float = 20.0

func _ready():
	$Timer.wait_time = cooldown
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	if projectile_scene == null: return
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	
	var temp_weapon = projectile_scene.instantiate()
	var is_melee_weapon = false
	
	if "is_melee" in temp_weapon and temp_weapon.is_melee:
		is_melee_weapon = true
		
	temp_weapon.queue_free()
	
	var base_direction = Vector2.RIGHT
	
	if is_melee_weapon:
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_dir.length() > 0:
			base_direction = input_dir.normalized()
		elif player.velocity.length() > 0:
			base_direction = player.velocity.normalized()
		else:
			var sprite = player.get_node_or_null("AnimatedSprite2D")
			if sprite and sprite.flip_h: base_direction = Vector2.LEFT
			else: base_direction = Vector2.RIGHT
	else:
		var target = player.find_nearest_enemy()
		if target:
			base_direction = player.global_position.direction_to(target.global_position)
		elif player.velocity.length() > 0:
			base_direction = player.velocity.normalized()

	var current_arc_deg = manual_arc_degrees
	if spread_degrees > 0 and projectile_count > 1:
		current_arc_deg = spread_degrees * (projectile_count - 1)
		if current_arc_deg >= 360: current_arc_deg = 360
	
	var arc_rad = deg_to_rad(current_arc_deg)
	var angle_step = 0
	if projectile_count > 1:
		if abs(current_arc_deg) >= 360: angle_step = arc_rad / projectile_count
		else: angle_step = arc_rad / (projectile_count - 1)
	var start_angle = -arc_rad / 2
	
	for i in range(projectile_count):
		var new_weapon = projectile_scene.instantiate()
		
		if is_melee_weapon:
			player.add_child(new_weapon) 
		else:
			get_tree().current_scene.add_child(new_weapon)
			new_weapon.global_position = player.global_position 
		
		var current_angle = 0
		if projectile_count > 1:
			current_angle = start_angle + (angle_step * i)
		
		var final_direction = base_direction.rotated(current_angle)
		
		if "direction" in new_weapon:
			new_weapon.direction = final_direction
		
		new_weapon.rotation = final_direction.angle()
		
		if is_melee_weapon and "relative_rotation" in new_weapon:
			new_weapon.relative_rotation = current_angle
