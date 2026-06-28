extends Node2D

@export var block_scene: PackedScene
@export var grid_size: int = 64 

@export_category("Configuración de Generación")
@export var number_of_clusters: int = 40 # 40 bosques en total
@export var blocks_per_cluster: int = 60 # 60 árboles por bosque
@export var individual_trees: int = 800 # Árboles sueltos por el mapa

@export var nav_region: NavigationRegion2D

var occupied_positions: Dictionary = {} 

var tree_families = [
	[ # Burned
		preload("res://Assets/Trees/Burned_tree1.png"),
		preload("res://Assets/Trees/Burned_tree2.png"),
		preload("res://Assets/Trees/Burned_tree3.png")
	],
	[ # Flower
		preload("res://Assets/Trees/Flower_tree1.png"),
		preload("res://Assets/Trees/Flower_tree2.png"),
		preload("res://Assets/Trees/Flower_tree2-1.png")
	],
	[ # Fruit
		preload("res://Assets/Trees/Fruit_tree1.png"),
		preload("res://Assets/Trees/Fruit_tree2.png"),
		preload("res://Assets/Trees/Fruit_tree3.png")
	],
	[ # Moss
		preload("res://Assets/Trees/Moss_tree1.png"),
		preload("res://Assets/Trees/Moss_tree2.png"),
		preload("res://Assets/Trees/Moss_tree3.png")
	]
]

func _ready():
	y_sort_enabled = true # Activamos Y-Sort para el generador
	
	if not nav_region:
		return

	setup_navigation_floor()
	generate_map()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	nav_region.bake_navigation_polygon()

func setup_navigation_floor():
	var new_poly = NavigationPolygon.new()

	var nav_half: float = Global.MAP_HALF_SIZE
	var outline = PackedVector2Array([
		Vector2(-nav_half, -nav_half),
		Vector2( nav_half, -nav_half),
		Vector2( nav_half,  nav_half),
		Vector2(-nav_half,  nav_half),
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
		
	# Generamos los árboles sueltos
	for i in range(individual_trees):
		_spawn_individual_tree(player_pos)

func _spawn_individual_tree(avoid_pos: Vector2):
	var half = Global.MAP_HALF_SIZE - 800 
	var center_x = randf_range(-half, half)
	var center_y = randf_range(-half, half)
	var tree_pos = snap_to_grid(Vector2(center_x, center_y))
	
	if tree_pos.distance_to(avoid_pos) < 1500:
		return
		
	if not occupied_positions.has(tree_pos):
		var tex = tree_families.pick_random().pick_random()
		
		var spawn_pos = tree_pos
		spawn_pos.y += randf_range(-0.5, 0.5)
		
		place_block(spawn_pos, tex)
		occupied_positions[tree_pos] = true

func _spawn_cluster(avoid_pos: Vector2):
	var half = Global.MAP_HALF_SIZE - 800 
	var center_x = randf_range(-half, half)
	var center_y = randf_range(-half, half)
	var cluster_center = snap_to_grid(Vector2(center_x, center_y))
	
	if cluster_center.distance_to(avoid_pos) < 1500:
		return

	var radius = randf_range(300, 700) 
	var step = grid_size
	var r_int = int(radius / step)
	
	for x in range(-r_int, r_int + 1):
		for y in range(-r_int, r_int + 1):
			var local_pos = Vector2(x * step, y * step)
			if local_pos.length() <= radius * randf_range(0.7, 1.1):
				var current_pos = snap_to_grid(cluster_center + local_pos)
				
				if not occupied_positions.has(current_pos):
					var tex = tree_families.pick_random().pick_random()
					
					# Para evitar que "vibren" (Y-Sort flickering), le sumamos un valor ínfimo y aleatorio a la posición Y
					# De esta forma, ningún árbol comparte exactamente la misma coordenada Y, por lo que Godot siempre sabe cuál va adelante.
					var spawn_pos = current_pos
					spawn_pos.y += randf_range(-0.5, 0.5)
					
					place_block(spawn_pos, tex)
					occupied_positions[current_pos] = true

func place_block(pos: Vector2, tex: Texture2D):
	var block = block_scene.instantiate()
	block.position = pos
	block.add_to_group("obstaculos")
	
	block.z_index = 0
	block.y_sort_enabled = true
	
	var rect = block.get_node_or_null("ColorRect")
	if rect:
		rect.queue_free()
		
	var sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.position = Vector2(0, -32) 
	sprite.scale = Vector2(2.5, 2.5) 
	
	# Usamos Nearest with Mipmaps para que al hacer zoom out (achicar la imagen) no "vibre" o "brille" (aliasing)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	
	# Bajamos un poco el brillo para que empasten mejor con el mapa
	var shade = randf_range(0.6, 0.8)
	sprite.modulate = Color(shade, shade, shade, 1.0)
	
	block.add_child(sprite)
	add_child(block) 

func snap_to_grid(pos: Vector2) -> Vector2:
	var x = round(pos.x / grid_size) * grid_size
	var y = round(pos.y / grid_size) * grid_size
	return Vector2(x, y)

func get_random_direction() -> Vector2:
	var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	return dirs.pick_random()
