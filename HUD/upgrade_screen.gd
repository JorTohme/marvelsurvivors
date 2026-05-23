extends CanvasLayer

const WEAPON_DATA: Dictionary = {
	"aura": {
		"name": "Aura",
		"description": "Área de daño permanente\nalrededor del jugador.",
		"color": Color(0.2, 0.7, 1.0),
		"scene_path": "res://Weapons/Aura/Aura.tscn",
	},
	"axe": {
		"name": "Hacha",
		"description": "Arma giratoria\ncuerpo a cuerpo.",
		"color": Color(0.7, 0.7, 0.85),
		"scene_path": "res://Weapons/Axe/Axe.tscn",
	},
	"bullet": {
		"name": "Bala",
		"description": "Disparo que apunta\nal enemigo más cercano.",
		"color": Color(1.0, 0.75, 0.1),
		"scene_path": "res://Weapons/Bullet/Bullet.tscn",
	},
}

var _weapon_manager: WeaponManager = null

func _ready():
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	Global.leveled_up.connect(_on_leveled_up)

func _on_leveled_up():
	_weapon_manager = get_tree().get_first_node_in_group("weapon_manager")
	var options: Array = WEAPON_DATA.keys()
	options.shuffle()
	options = options.slice(0, min(3, options.size()))
	_show_cards(options)

func _show_cards(weapon_ids: Array):
	get_tree().paused = true

	for child in get_children():
		child.queue_free()

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.65)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "¡SUBISTE DE NIVEL!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(-400, 120)
	title.size = Vector2(800, 70)
	add_child(title)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_CENTER)
	hbox.position = Vector2(-450, -140)
	hbox.size = Vector2(900, 300)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 30)
	add_child(hbox)

	for weapon_id in weapon_ids:
		hbox.add_child(_create_card(weapon_id))

	show()

func _create_card(weapon_id: String) -> Control:
	var data: Dictionary = WEAPON_DATA[weapon_id]
	var already_have: bool = _weapon_manager != null and _weapon_manager.has_weapon(weapon_id)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(260, 280)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var icon := ColorRect.new()
	icon.color = data["color"]
	icon.custom_minimum_size = Vector2(260, 110)
	vbox.add_child(icon)

	var name_label := Label.new()
	name_label.text = data["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = data["description"]
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	var btn := Button.new()
	btn.text = "MEJORAR" if already_have else "OBTENER"
	btn.pressed.connect(func(): _on_card_selected(weapon_id))
	vbox.add_child(btn)

	return panel

func _on_card_selected(weapon_id: String):
	if _weapon_manager:
		var scene: PackedScene = load(WEAPON_DATA[weapon_id]["scene_path"])
		_weapon_manager.add_weapon(weapon_id, scene)

	for child in get_children():
		child.queue_free()
	hide()
	get_tree().paused = false
