extends Label

func _process(_delta):
	if Global.time_left > 0:
		var t := int(Global.time_left)
		text = "%02d:%02d" % [t / 60, t % 60]
		modulate = Color.WHITE
	else:
		var t := int(Global.overtime)
		text = "+%02d:%02d" % [t / 60, t % 60]
		modulate = Color(1.0, 0.85, 0.0)
