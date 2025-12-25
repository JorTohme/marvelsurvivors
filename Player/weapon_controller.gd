extends Node2D

@export_category("Configuración Principal")
@export var weapon_scene: PackedScene # Aquí arrastras el Hacha, el Aura o la Bala
@export var cooldown: float = 1.0

@export_category("Comportamiento")
@export var projectile_count: int = 1

@export_group("Ángulos y Dispersión")
@export var manual_arc_degrees: float = 0.0 
@export var spread_degrees: float = 20.0

var _is_melee: bool = false
var _is_aura: bool = false
var _aura_active_instance: Node = null

@onready var timer = $Timer
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	if not weapon_scene:
		set_process(false)
		return
		
	_analyze_weapon_type()
	
	if _is_aura:
		_equip_aura()
		timer.stop()
	else:
		timer.wait_time = cooldown
		timer.timeout.connect(_on_timer_timeout)
		timer.start()

func _analyze_weapon_type():
	var temp = weapon_scene.instantiate()
	
	if "is_aura" in temp and temp.is_aura:
		_is_aura = true

	elif temp.has_method("level_up_aura"): 
		_is_aura = true
		
	if "is_melee" in temp and temp.is_melee:
		_is_melee = true
	
	temp.queue_free()

func _equip_aura():
	if _aura_active_instance == null:
		_aura_active_instance = weapon_scene.instantiate()
		player.call_deferred("add_child", _aura_active_instance)
		_aura_active_instance.position = Vector2.ZERO
	else:
		if _aura_active_instance.has_method("level_up_aura"):
			_aura_active_instance.level_up_aura()

func _on_timer_timeout():
	if not player: return

	var base_direction = Vector2.RIGHT
	
	if _is_melee:
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_dir.length() > 0:
			base_direction = input_dir.normalized()
		elif player.velocity.length() > 0:
			base_direction = player.velocity.normalized()
		else:
			# Asumiendo que usas AnimatedSprite2D para la cara
			var sprite = player.get_node_or_null("AnimatedSprite2D")
			if sprite and sprite.flip_h: base_direction = Vector2.LEFT
			else: base_direction = Vector2.RIGHT
	else:
		# Lógica Rango: Prioriza Enemigo más cercano -> Movimiento
		var target = player.find_nearest_enemy()
		if target:
			base_direction = player.global_position.direction_to(target.global_position)
		elif player.velocity.length() > 0:
			base_direction = player.velocity.normalized()

	var current_arc_deg = manual_arc_degrees
	if spread_degrees > 0 and projectile_count > 1:
		current_arc_deg = spread_degrees * (projectile_count - 1)
		current_arc_deg = min(current_arc_deg, 360) # Clamp a 360
	
	var arc_rad = deg_to_rad(current_arc_deg)
	var angle_step = 0
	if projectile_count > 1:
		angle_step = arc_rad / (projectile_count if abs(current_arc_deg) >= 360 else (projectile_count - 1))
	
	var start_angle = -arc_rad / 2
	
	for i in range(projectile_count):
		var new_weapon = weapon_scene.instantiate()
		
		if _is_melee:
			player.add_child(new_weapon)
		else:
			get_tree().current_scene.add_child(new_weapon)
			new_weapon.global_position = player.global_position
		
		var current_angle_offset = 0
		if projectile_count > 1:
			current_angle_offset = start_angle + (angle_step * i)
		
		var final_direction = base_direction.rotated(current_angle_offset)
		
		if "direction" in new_weapon:
			new_weapon.direction = final_direction
		
		new_weapon.rotation = final_direction.angle()
		
		if _is_melee and "relative_rotation" in new_weapon:
			new_weapon.relative_rotation = current_angle_offset
