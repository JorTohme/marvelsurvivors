extends Node2D

@export var enemy_scene: PackedScene 
@export var elite_chance: float = 0.05

@export var initial_spawn_time: float = 4.0
@export var min_spawn_time: float = 0.5
@export var time_reduction_per_minute: float = 0.15

func _ready():
	$Timer.wait_time = initial_spawn_time
	$Timer.timeout.connect(_on_timer_timeout)

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
		var min_enemies = 1 + minute
		var max_enemies = 3 + int(minute * 1.5)
		
		if is_close_spawn:
			max_enemies = max(1, int(max_enemies / 2))
		
		var group_size = randi_range(min_enemies, max_enemies)
		
		for i in range(group_size):
			var new_enemy = enemy_scene.instantiate()
			
			var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
			new_enemy.global_position = group_center + offset
			
			if randf() < elite_chance:
				new_enemy.make_elite()
			
			get_tree().current_scene.add_child(new_enemy)
			
	_update_timer_speed()

func _update_timer_speed():
	var minute = Global.get_current_minute()
	var new_wait_time = initial_spawn_time - (time_reduction_per_minute * minute)
	
	$Timer.wait_time = max(min_spawn_time, new_wait_time)

func get_smart_spawn_position(player_node, radius_min, radius_max) -> Vector2:
	for i in range(4):
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
	query.collision_mask = 1
	
	var result = space_state.intersect_point(query)
	
	return result.is_empty()
