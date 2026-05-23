extends Control

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS

	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.position = Vector2(-200, -150)
	vbox.size = Vector2(400, 300)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	add_child(vbox)

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

func _on_play():
	Global.reset()
	get_tree().change_scene_to_file("res://Global/World.tscn")

func _on_quit():
	get_tree().quit()
