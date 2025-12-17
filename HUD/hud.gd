extends CanvasLayer

@onready var xp_bar = $ProgressBar
@onready var level_label = $LabelLevel

func _process(_delta):
	var max_xp = Global.next_level_xp
	var current_xp = Global.current_xp
	
	xp_bar.value = current_xp
	xp_bar.max_value = max_xp
