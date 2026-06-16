extends Area2D

@onready var sprite = $Sprite2D
@onready var prompt_label = $PromptLabel

var player_in_range = false
var is_open = false

@export var is_golden: bool = false

func _ready():
	prompt_label.visible = false
	sprite.modulate = Color(1, 1, 1, 1) # Resetear el tinte del sprite por defecto
	sprite.scale = Vector2(0.12, 0.12) # Achicamos la imagen generada (de 1024x1024 a ~120px)
	
	if is_golden:
		sprite.texture = load("res://Structures/Chest/golden_chest.png")
		prompt_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.0))
	else:
		sprite.texture = load("res://Structures/Chest/normal_chest.png")
	
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

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false
