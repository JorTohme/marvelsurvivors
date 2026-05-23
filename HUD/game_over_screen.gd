extends CanvasLayer

func _ready():
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_over_screen")
	hide()

func show_game_over(survived_seconds: float):
	get_tree().paused = true

	for child in get_children():
		child.queue_free()

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.position = Vector2(-200, -120)
	vbox.size = Vector2(400, 240)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	add_child(vbox)

	var title := Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	vbox.add_child(title)

	var minutes := int(survived_seconds) / 60
	var seconds := int(survived_seconds) % 60
	var time_label := Label.new()
	time_label.text = "Sobreviviste %d:%02d" % [minutes, seconds]
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(time_label)

	var level_label := Label.new()
	level_label.text = "Nivel alcanzado: %d" % Global.level
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(level_label)

	var btn := Button.new()
	btn.text = "REINTENTAR"
	btn.custom_minimum_size = Vector2(200, 50)
	btn.pressed.connect(_on_retry)
	vbox.add_child(btn)

	show()

func _on_retry():
	get_tree().paused = false
	get_tree().reload_current_scene()
