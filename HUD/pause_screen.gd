extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	hide()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause():
	var is_paused = get_tree().paused
	
	# Si está pausado pero no estamos mostrando la pantalla de pausa, significa que
	# estamos en un cofre, nivel o game over. No despausamos.
	if is_paused and not visible:
		return
		
	if visible:
		hide()
		get_tree().paused = false
	else:
		show()
		get_tree().paused = true

func _on_continue_pressed():
	_toggle_pause()

func _on_quit_pressed():
	get_tree().quit()
