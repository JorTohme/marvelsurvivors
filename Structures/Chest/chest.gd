extends Area2D

@onready var sprite = $Sprite2D
@onready var prompt_label = $PromptLabel
var outline_shader = preload("res://Structures/Magnet/MagnetStructure.gdshader")

var player_in_range = false
var is_open = false

@export var is_golden: bool = false

func _ready():
	prompt_label.visible = false
	sprite.modulate = Color(1, 1, 1, 1) # Resetear el tinte del sprite por defecto
	sprite.scale = Vector2(0.22, 0.22) # Escala ajustada, era muy chica antes
	
	var mat = ShaderMaterial.new()
	mat.shader = outline_shader
	mat.set_shader_parameter("line_color", Color(1,1,1,1))
	mat.set_shader_parameter("line_thickness", -1.0)
	sprite.material = mat
	
	var path = "res://Structures/Chest/normal_chest.png"
	if ResourceLoader.exists(path):
		sprite.texture = load(path)
	elif FileAccess.file_exists(path):
		var img = Image.load_from_file(ProjectSettings.globalize_path(path))
		if img:
			sprite.texture = ImageTexture.create_from_image(img)
	
	if is_golden:
		prompt_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.0))
		sprite.material.set_shader_parameter("line_thickness", 25.0)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	if is_open:
		return
		
	if player_in_range:
		var cost = 0 if is_golden else Global.get_chest_cost()
		prompt_label.text = "¡Gratis!" if is_golden else str(cost) + " Oro"
		
		if Input.is_key_pressed(KEY_E):
			_try_open_chest(cost)

func _try_open_chest(cost: int):
	var is_free_lockpick = randf() < (Global.items.get("broken_lockpick", 0) * 0.01)
	
	if is_golden or is_free_lockpick or Global.spend_gold(cost):
		is_open = true
		Global.chests_opened += 1
		prompt_label.visible = false
		sprite.modulate = Color(0.5, 0.5, 0.5) # Feedback visual de abierto
		sprite.material.set_shader_parameter("line_thickness", -1.0)
		
		# Mostrar la UI del cofre
		var screen = get_tree().get_first_node_in_group("chest_screen")
		if screen:
			screen.show_chest()
		else:
			push_error("No se encontró el chest_screen en el grupo 'chest_screen'.")

func _on_body_entered(body):
	if not is_open and body.is_in_group("player"):
		player_in_range = true
		prompt_label.visible = true
		sprite.material.set_shader_parameter("line_thickness", 25.0)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false
		if not is_golden and not is_open:
			sprite.material.set_shader_parameter("line_thickness", -1.0)
