extends Node2D

@export var magnet_scene: PackedScene
@export var prop_scene: PackedScene
@export var amount: int = 200

func _ready():
	generate_world()
	_spawn_world_border()
	AudioManager.play_music("gameplay")

func _spawn_world_border() -> void:
	var half: float = Global.MAP_HALF_SIZE
	var line := Line2D.new()
	line.default_color = Color(1.0, 0.2, 0.2, 0.5)
	line.width = 6.0
	line.points = PackedVector2Array([
		Vector2(-half, -half),
		Vector2( half, -half),
		Vector2( half,  half),
		Vector2(-half,  half),
		Vector2(-half, -half),
	])
	add_child(line)

func generate_world():
	var half: float = Global.MAP_HALF_SIZE

	for i in range(amount):
		var new_prop = prop_scene.instantiate()
		new_prop.position = Vector2(randf_range(-half, half), randf_range(-half, half))
		add_child(new_prop)

	for i in range(3):
		var magnet = magnet_scene.instantiate()
		magnet.position = Vector2(randf_range(-half, half), randf_range(-half, half))
		add_child(magnet)
