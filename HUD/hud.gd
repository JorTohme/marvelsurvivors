extends CanvasLayer

const MAX_WEAPONS := 3

const WEAPON_DISPLAY: Dictionary = {
	"aura":   { "name": "Aura",  "color": Color(0.2, 0.7, 1.0) },
	"axe":    { "name": "Hacha", "color": Color(0.7, 0.7, 0.85) },
	"bullet": { "name": "Bala",  "color": Color(1.0, 0.75, 0.1) },
	"arrow":  { "name": "Arco",  "color": Color(0.8, 1.0, 0.2) },
}

const MAX_TOMES := 5
const TOME_DISPLAY: Dictionary = {
	"damage": { "name": "Daño", "color": Color(0.9, 0.2, 0.2) },
	"quantity": { "name": "Cant.", "color": Color(0.2, 0.8, 0.3) },
	"knockback": { "name": "Empuje", "color": Color(0.9, 0.5, 0.1) },
	"size": { "name": "Tamaño", "color": Color(0.7, 0.2, 0.9) },
	"luck": { "name": "Suerte", "color": Color(0.8, 0.9, 0.2) },
	"attack_speed": { "name": "Veloc.", "color": Color(0.1, 0.8, 0.9) },
	"regen": { "name": "Regen", "color": Color(0.9, 0.2, 0.6) },
	"proj_speed": { "name": "Proyec.", "color": Color(0.3, 1.0, 0.6) },
}

@onready var xp_bar = $ProgressBar
@onready var level_label = $LabelLevel

var _slots: Array = []
var _tome_slots: Array = []
var _gold_label: Label

func _ready():
	_build_weapon_slots()
	_build_tome_slots()
	
	_gold_label = Label.new()
	_gold_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_gold_label.position = Vector2(-200, 50)
	_gold_label.add_theme_font_size_override("font_size", 24)
	_gold_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	add_child(_gold_label)
	
	_update_gold_label()
	Global.gold_changed.connect(_update_gold_label)

func _update_gold_label():
	if _gold_label:
		_gold_label.text = "Oro: " + str(Global.gold)

func _process(_delta):
	xp_bar.value = Global.current_xp
	xp_bar.max_value = Global.next_level_xp
	_update_weapon_slots()
	_update_tome_slots()

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

func _build_tome_slots() -> void:
	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_TOP_LEFT)
	hbox.position = Vector2(10, 130) # Debajo de las armas
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)

	for i in range(MAX_TOMES):
		var slot := _create_slot()
		slot["control"].custom_minimum_size = Vector2(40, 40) # Un poco más chicos que las armas
		hbox.add_child(slot["control"])
		_tome_slots.append(slot)

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

func _update_tome_slots() -> void:
	var tomes = Global.acquired_tomes
	for i in range(MAX_TOMES):
		var slot: Dictionary = _tome_slots[i]
		if i < tomes.size():
			var data: Dictionary = TOME_DISPLAY.get(tomes[i], { "name": "?", "color": Color(0.4, 0.4, 0.4) })
			slot["bg"].color = data["color"]
			slot["label"].text = data["name"]
		else:
			slot["bg"].color = Color(0.15, 0.15, 0.15, 0.8)
			slot["label"].text = ""
