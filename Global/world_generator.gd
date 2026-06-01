extends Node2D

@export var magnet_scene: PackedScene
@export var prop_scene: PackedScene
@export var amount: int = 1000 # Escaldo para el mapa de 20k x 20k

func _ready():
	generate_world()
	_spawn_world_border()
	AudioManager.play_music("gameplay")

func _spawn_world_border() -> void:
	var half: float = Global.MAP_HALF_SIZE
	var line := Line2D.new()
	line.default_color = Color(1.0, 0.2, 0.2, 0.5)
	line.width = 10.0
	var points_array = PackedVector2Array([
		Vector2(-half, -half),
		Vector2( half, -half),
		Vector2( half,  half),
		Vector2(-half,  half),
		Vector2(-half, -half),
	])
	line.points = points_array
	add_child(line)

	var border_body = $"../WorldBorder"
	if border_body:
		for i in range(4):
			var shape = CollisionShape2D.new()
			var segment = SegmentShape2D.new()
			segment.a = points_array[i]
			segment.b = points_array[i+1]
			shape.shape = segment
			border_body.add_child(shape)

func generate_world():
	var half: float = Global.MAP_HALF_SIZE

	_spawn_grass_patches(half)

	for i in range(amount):
		var new_prop = prop_scene.instantiate()
		new_prop.position = Vector2(randf_range(-half, half), randf_range(-half, half))
		add_child(new_prop)

	for i in range(3):
		var magnet = magnet_scene.instantiate()
		magnet.position = Vector2(randf_range(-half, half), randf_range(-half, half))
		add_child(magnet)

func _spawn_grass_patches(half: float) -> void:
	var patch_textures = [
		load("res://Assets/Enviroment/grass05.png"),
		load("res://Assets/Enviroment/grass10.png"),
		load("res://Assets/Enviroment/grass14.png")
	]
	
	# Bajamos la cantidad a 15 para que sean extremadamente raras
	var num_clusters = 15
	var placed_centers = []
	
	for c in range(num_clusters):
		var cluster_center = Vector2.ZERO
		var valid = false
		var attempts = 0
		
		# Buscar una posición que esté MUY alejada de las demás manchas
		while not valid and attempts < 200:
			cluster_center = Vector2(randf_range(-half, half), randf_range(-half, half))
			valid = true
			for pos in placed_centers:
				if cluster_center.distance_to(pos) < 8000.0: # Distancia colosal
					valid = false
					break
			attempts += 1
			
		placed_centers.append(cluster_center)
		
		var tex = patch_textures.pick_random()
		var poly = Polygon2D.new()
		poly.texture = tex
		poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		poly.scale = Vector2(2, 2)
		poly.z_index = -5 
		poly.position = cluster_center
		
		var points = PackedVector2Array()
		var num_points = 12
		var base_radius = randf_range(200, 600) 
		for i in range(num_points):
			var angle = i * (TAU / num_points)
			var r = base_radius * randf_range(0.6, 1.4) 
			points.append(Vector2(cos(angle), sin(angle)) * r)
			
		poly.polygon = points
		
		var tint = randf_range(0.75, 0.95)
		poly.modulate = Color(tint, tint, tint, 0.85) 
		
		add_child(poly)
