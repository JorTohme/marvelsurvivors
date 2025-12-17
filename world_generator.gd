extends Node2D

@export var magnet_scene: PackedScene

@export var prop_scene: PackedScene
@export var amount: int = 200   
@export var map_size: int = 2000

func _ready():
	generate_world()

func generate_world():
	for i in range(amount):
		var new_prop = prop_scene.instantiate()
		
		var x = randf_range(-map_size, map_size)
		var y = randf_range(-map_size, map_size)
		
		new_prop.position = Vector2(x, y)
		
		add_child(new_prop)
		
	for i in range(3):
		var magnet = magnet_scene.instantiate()
		magnet.position = Vector2(randf_range(-map_size, map_size), randf_range(-map_size, map_size))
		add_child(magnet)
