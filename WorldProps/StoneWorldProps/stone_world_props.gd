extends Sprite2D

@export var textures: Array[Texture2D] 

func _ready():
	if textures.size() > 0:
		texture = textures.pick_random()
	
	# rotation = randf() * TAU 
	
	var random_scale = randf_range(0.10, 0.15)
	scale = Vector2(random_scale, random_scale)
	var brightness = randf_range(0.3, 0.5)
	modulate = Color(brightness, brightness, brightness, 1)
