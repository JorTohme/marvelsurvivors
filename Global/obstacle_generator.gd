extends Node2D

@export var block_scene: PackedScene
@export var grid_size: int = 64 

@export_category("Configuración de Generación")
@export var number_of_clusters: int = 10
@export var blocks_per_cluster: int = 15
@export var map_limit_x: Vector2 = Vector2(-1000, 1000)
@export var map_limit_y: Vector2 = Vector2(-1000, 1000)

@export var nav_region: NavigationRegion2D

var occupied_positions: Dictionary = {} 

func _ready():
	if not nav_region:
		return

	setup_navigation_floor()
	generate_map()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	nav_region.bake_navigation_polygon()

func setup_navigation_floor():
	var new_poly = NavigationPolygon.new()
	
	var outline = PackedVector2Array([
		Vector2(map_limit_x.x - 500, map_limit_y.x - 500),
		Vector2(map_limit_x.y + 500, map_limit_y.x - 500),
		Vector2(map_limit_x.y + 500, map_limit_y.y + 500),
		Vector2(map_limit_x.x - 500, map_limit_y.y + 500)
	])
	
	new_poly.add_outline(outline)
	new_poly.make_polygons_from_outlines()
	new_poly.agent_radius = 45.0
	
	new_poly.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_EXPLICIT
	
	new_poly.source_geometry_group_name = "obstaculos"
	
	new_poly.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	
	nav_region.navigation_polygon = new_poly

func generate_map():
	var player = get_tree().get_first_node_in_group("player")
	var player_pos = Vector2.ZERO
	if player: player_pos = player.global_position
	
	for i in range(number_of_clusters):
		_spawn_cluster(player_pos)

func _spawn_cluster(avoid_pos: Vector2):
	var start_x = randi_range(map_limit_x.x, map_limit_x.y)
	var start_y = randi_range(map_limit_y.x, map_limit_y.y)
	
	var current_pos = snap_to_grid(Vector2(start_x, start_y))
	
	if current_pos.distance_to(avoid_pos) < 300:
		return

	for i in range(blocks_per_cluster):
		if not occupied_positions.has(current_pos):
			place_block(current_pos)
			occupied_positions[current_pos] = true
		
		var direction = get_random_direction()
		current_pos += direction * grid_size
		
		if randf() < 0.3:
			current_pos = snap_to_grid(Vector2(start_x, start_y))

func place_block(pos: Vector2):
	var block = block_scene.instantiate()
	block.position = pos
	block.add_to_group("obstaculos")
	add_child(block) 

func snap_to_grid(pos: Vector2) -> Vector2:
	var x = round(pos.x / grid_size) * grid_size
	var y = round(pos.y / grid_size) * grid_size
	return Vector2(x, y)

func get_random_direction() -> Vector2:
	var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	return dirs.pick_random()
