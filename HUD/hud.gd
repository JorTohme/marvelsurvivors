extends CanvasLayer

const MAX_WEAPONS := 3

const WEAPON_DISPLAY: Dictionary = {
	"aura":   { "name": "Aura",  "color": Color(0.2, 0.7, 1.0) },
	"axe":    { "name": "Hacha", "color": Color(0.7, 0.7, 0.85) },
	"bullet": { "name": "Bala",  "color": Color(1.0, 0.75, 0.1) },
}

@onready var xp_bar = $ProgressBar
@onready var level_label = $LabelLevel

var _slots: Array = []

func _ready():
	_build_weapon_slots()

func _process(_delta):
	xp_bar.value = Global.current_xp
	xp_bar.max_value = Global.next_level_xp
	_update_weapon_slots()

func _build_weapon_slots() -> void:
	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_TOP_LEFT)
	hbox.position = Vector2(10, 70)
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)

	for i in range(MAX_WEAPONS):
		var slot := _create_slot()
		hbox.add_child(slot["control"])
		_slots.append(slot)

func _create_slot() -> Dictionary:
	var control := Control.new()
	control.custom_minimum_size = Vector2(52, 52)

	var bg := ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.15, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.add_child(bg)

	var lbl := Label.new()
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 9)
	control.add_child(lbl)

	return { "control": control, "bg": bg, "label": lbl }

func _update_weapon_slots() -> void:
	var manager: WeaponManager = get_tree().get_first_node_in_group("weapon_manager")
	var active: Array = manager.get_active_weapon_ids() if manager else []

	for i in range(MAX_WEAPONS):
		var slot: Dictionary = _slots[i]
		if i < active.size():
			var data: Dictionary = WEAPON_DISPLAY.get(active[i], { "name": "?", "color": Color(0.4, 0.4, 0.4) })
			slot["bg"].color = data["color"]
			slot["label"].text = data["name"]
		else:
			slot["bg"].color = Color(0.15, 0.15, 0.15, 0.8)
			slot["label"].text = ""
