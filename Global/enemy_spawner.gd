extends Node2D

@export var enemy_scene: PackedScene 
@export var elite_chance: float = 0.05

@export var initial_spawn_time: float = 4.0
@export var min_spawn_time: float = 0.5
@export var time_reduction_per_minute: float = 0.15

var superhorde_count: int = 0
var next_superhorde_time: float = 5.0
var miniboss_spawned: bool = false
var boss_spawned: bool = false

func _ready():
	$Timer.wait_time = initial_spawn_time
	$Timer.timeout.connect(_on_timer_timeout)

func _process(delta):
	var elapsed = Global.get_time_elapsed()
	
	if not miniboss_spawned and elapsed >= 1.0: # Minuto 5 (ahora a 1s para probar)
		miniboss_spawned = true
		_spawn_specific_boss("miniboss")
		
	if not boss_spawned and elapsed >= 2.0: # Minuto 8 (ahora a 2s para probar)
		boss_spawned = true
		_spawn_specific_boss("boss")
		
	if Global.time_left <= 0 and Global.overtime >= next_superhorde_time:
		_spawn_super_horde()
		superhorde_count += 1
		next_superhorde_time += 40.0

func _on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		var min_dist = 600.0
		var max_dist = 1000.0
		var is_close_spawn = false
		
		if randf() < 0.1: 
			min_dist = 500.0
			max_dist = 600.0
			is_close_spawn = true

		var group_center = get_smart_spawn_position(player, min_dist, max_dist)
		
		var minute = Global.get_current_minute()
		var min_enemies = 1 + int(minute * 0.5)
		var max_enemies = 1 + minute
		
		if is_close_spawn:
			max_enemies = max(1, int(max_enemies / 2))
		
		var group_size = randi_range(min_enemies, max_enemies)
		
		# Después de 30 segundos, hay chance de que el grupo sea de corredores
		var is_runner_group = false
		if Global.get_time_elapsed() > 30.0 and randf() < 0.3:
			is_runner_group = true
			group_size += 2 # Los corredores vienen en grupos un poco más grandes
			
		# Después de 60 segundos, hay chance de que el grupo sea de casters
		var is_caster_group = false
		if Global.get_time_elapsed() > 60.0 and randf() < 0.2 and not is_runner_group:
			is_caster_group = true
		
		for i in range(group_size):
			var new_enemy = enemy_scene.instantiate()
			
			# Intentamos encontrar una posición libre cercana al centro del grupo
			var spawn_pos = group_center
			var found_valid_pos = false
			for attempt in range(10):
				var offset = Vector2(randf_range(-60, 60), randf_range(-60, 60))
				if is_position_free(group_center + offset):
					spawn_pos = group_center + offset
					found_valid_pos = true
					break
					
			# Si no encontró lugar libre después de 10 intentos (ej. bosque muy denso), no lo spawnea
			if not found_valid_pos:
				new_enemy.queue_free()
				continue
				
			new_enemy.global_position = spawn_pos
			
			if randf() < elite_chance:
				new_enemy.make_elite()
			elif is_runner_group:
				new_enemy.make_runner()
			elif is_caster_group:
				new_enemy.make_caster()
			
			get_tree().current_scene.add_child(new_enemy)
			
	_update_timer_speed()

func _update_timer_speed():
	var minute = Global.get_current_minute()
	var new_wait_time = initial_spawn_time - (time_reduction_per_minute * minute)
	
	$Timer.wait_time = max(min_spawn_time, new_wait_time)

func get_smart_spawn_position(player_node, radius_min, radius_max) -> Vector2:
	for i in range(15):
		var random_angle = randf() * TAU
		var random_distance = randf_range(radius_min, radius_max)
		
		var potential_pos = player_node.global_position + Vector2(cos(random_angle), sin(random_angle)) * random_distance
		
		if is_position_free(potential_pos):
			return potential_pos
			
	var fallback_angle = randf() * TAU
	return player_node.global_position + Vector2(cos(fallback_angle), sin(fallback_angle)) * radius_max

func is_position_free(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	# Máscara 4 corresponde a la capa 'World'. Máscara 1 es 'Player'.
	# Evaluamos las capas 3 (World = valor 4), para no spawnear en bosques.
	query.collision_mask = 4 
	
	var result = space_state.intersect_point(query)
	
	return result.is_empty()

func _spawn_super_horde():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var count = 120
		var radius = 800.0
		for i in range(count):
			var angle = (float(i) / float(count)) * TAU
			var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * radius
			
			var new_enemy = enemy_scene.instantiate()
			
			# Ajustamos si es necesario buscar una posición libre
			var valid_pos = spawn_pos
			for attempt in range(5):
				if is_position_free(valid_pos):
					break
				valid_pos += Vector2(randf_range(-30, 30), randf_range(-30, 30))
			
			new_enemy.global_position = valid_pos
			
			if superhorde_count < 2:
				new_enemy.make_runner()
			
			
			get_tree().current_scene.add_child(new_enemy)
			
		initial_spawn_time = 0.2
		min_spawn_time = 0.2
		$Timer.wait_time = 0.2

func _spawn_specific_boss(type: String):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var spawn_pos = get_smart_spawn_position(player, 600.0, 800.0)
		var new_enemy = enemy_scene.instantiate()
		
		var valid_pos = spawn_pos
		for attempt in range(5):
			if is_position_free(valid_pos):
				break
			valid_pos += Vector2(randf_range(-30, 30), randf_range(-30, 30))
			
		new_enemy.global_position = valid_pos
		
		if type == "miniboss":
			new_enemy.make_miniboss()
		elif type == "boss":
			new_enemy.make_boss()
			
		get_tree().current_scene.add_child(new_enemy)
