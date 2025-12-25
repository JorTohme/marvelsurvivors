extends Label

@export var total_time: float = 600.0 

var time_left: float 

func _ready():
	time_left = total_time

func _process(_delta):
	var t = Global.time_left
	var minutes = floor(t / 60)
	var seconds = int(t) % 60
	text = "%02d:%02d" % [minutes, seconds]

func _update_text_display():
	var minutes = floor(time_left / 60)
	
	var seconds = int(time_left) % 60
	text = "%02d:%02d" % [minutes, seconds]
