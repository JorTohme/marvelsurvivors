extends Area2D

var player_in_range = null
var is_used = false

@onready var sprite = $Sprite2D 

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	var path = "res://Structures/Magnet/magnet.png"
	if ResourceLoader.exists(path):
		sprite.texture = load(path)
	elif FileAccess.file_exists(path):
		var img = Image.load_from_file(ProjectSettings.globalize_path(path))
		if img:
			sprite.texture = ImageTexture.create_from_image(img)
			
	sprite.scale = Vector2(0.12, 0.12) # Ajustar la escala de 1024x1024 a ~120px
	sprite.material.set_shader_parameter("line_thickness", -1.0)

func _input(event):
	if not is_used and player_in_range and event.is_action_pressed("interact"):
		activate_magnet()

func activate_magnet():
	sprite.material.set_shader_parameter("line_thickness", -1.0)
	
	var all_gems = get_tree().get_nodes_in_group("gems")
	for gem in all_gems:
		if is_instance_valid(gem):
			gem.start_collection_animation(player_in_range)
	
	
	is_used = true
	sprite.modulate = Color(0.3, 0.3, 0.3)
	sprite.material.set_shader_parameter("line_thickness", 0.0)


func _on_body_entered(body):
	if not is_used and body.is_in_group("player"):
		player_in_range = body
		sprite.material.set_shader_parameter("line_thickness", 25.0)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = null
		sprite.material.set_shader_parameter("line_thickness", 0.0)
