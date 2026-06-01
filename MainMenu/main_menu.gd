extends CanvasLayer

var bg: TextureRect

func _ready():
	layer = 0
	process_mode = Node.PROCESS_MODE_ALWAYS

	bg = TextureRect.new()
	bg.texture = load("res://Assets/Enviroment/grass19.png")
	bg.stretch_mode = TextureRect.STRETCH_TILE
	bg.size = Vector2(4000, 4000)
	bg.scale = Vector2(2, 2)
	bg.modulate = Color(0.4, 0.4, 0.4, 1.0) # Oscurecemos un poco para que resalte el texto
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(400, 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "MARVEL SURVIVORS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)

	var btn_play := Button.new()
	btn_play.text = "JUGAR"
	btn_play.custom_minimum_size = Vector2(200, 60)
	btn_play.pressed.connect(_on_play)
	vbox.add_child(btn_play)

	var btn_quit := Button.new()
	btn_quit.text = "SALIR"
	btn_quit.custom_minimum_size = Vector2(200, 60)
	btn_quit.pressed.connect(_on_quit)
	vbox.add_child(btn_quit)

func _process(delta):
	if bg and bg.texture:
		bg.position += Vector2(-50, -50) * delta
		var w = bg.texture.get_width() * bg.scale.x
		var h = bg.texture.get_height() * bg.scale.y
		if bg.position.x <= -w: bg.position.x += w
		if bg.position.y <= -h: bg.position.y += h

func _on_play():
	Global.reset()
	SceneTransition.change_scene_to_file("res://Global/World.tscn")

func _on_quit():
	get_tree().quit()
