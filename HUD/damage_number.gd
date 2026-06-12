extends Label

func setup(amount: int, is_crit: bool = false, is_heal: bool = false) -> void:
	if is_heal:
		text = "+" + str(amount)
		add_theme_font_size_override("font_size", 20)
		modulate = Color(0.2, 0.9, 0.2)
	else:
		text = ("CRIT! " if is_crit else "") + str(amount)
		add_theme_font_size_override("font_size", 24 if is_crit else 18)
		modulate = Color(1.0, 0.85, 0.0) if is_crit else Color(1.0, 0.25, 0.25)
		
	z_index = 10

	var travel := 80.0 if is_crit else 55.0
	var duration := 0.9 if is_crit else 0.75

	if is_heal:
		travel = 45.0
		duration = 1.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - travel, duration)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.chain().tween_callback(queue_free)
