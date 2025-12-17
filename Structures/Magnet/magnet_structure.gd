extends Area2D

var player_in_range = null

@onready var sprite = $Sprite2D 

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	sprite.material.set_shader_parameter("line_thickness", -1.0)

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		activate_magnet()

func activate_magnet():
	sprite.material.set_shader_parameter("line_thickness", -1.0)
	
	var all_gems = get_tree().get_nodes_in_group("gems")
	for gem in all_gems:
		if is_instance_valid(gem):
			gem.start_collection_animation(player_in_range)
	
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = body
		sprite.material.set_shader_parameter("line_thickness", 25.0)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = null
		sprite.material.set_shader_parameter("line_thickness", 0.0)
