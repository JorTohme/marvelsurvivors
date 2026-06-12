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
	"arrow": {
		"name": "Arco",
		"description": "Dispara flechas en abanico.",
		"color": Color(0.8, 1.0, 0.2),
		"scene_path": "res://Weapons/Arrow/arrow.tscn",
		"config": { "projectile_count": 1 },
	},
}

const TOME_DATA: Dictionary = {
	"damage": {
		"name": "Tomo de Daño",
		"description": "+10% daño\na todas las armas.",
		"color": Color(0.9, 0.2, 0.2),
	},
	"quantity": {
		"name": "Tomo de Cantidad",
		"description": "+1 proyectil\n(no aplica al Aura).",
		"color": Color(0.2, 0.8, 0.3),
	},
	"knockback": {
		"name": "Tomo de Knockback",
		"description": "+25% empuje\n(no aplica al Aura).",
		"color": Color(0.9, 0.5, 0.1),
	},
	"size": {
		"name": "Tomo de Tamaño",
		"description": "+20% tamaño\na todas las armas.",
		"color": Color(0.7, 0.2, 0.9),
	},
	"luck": {
		"name": "Tomo de Suerte",
		"description": "+1 Suerte\n(mejores rarezas).",
		"color": Color(0.8, 0.9, 0.2),
	},
	"attack_speed": {
		"name": "Tomo de Velocidad",
		"description": "+20% velocidad de ataque\n(no aplica al Aura).",
		"color": Color(0.1, 0.8, 0.9),
	},
	"regen": {
		"name": "Tomo de Vitalidad",
		"description": "+1 PV/s de\nregeneración de vida.",
		"color": Color(0.9, 0.2, 0.6),
	},
	"proj_speed": {
		"name": "Tomo de Rapidez",
		"description": "+25% veloc. de proyectil\n(solo proyectiles).",
		"color": Color(0.3, 1.0, 0.6),
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

	var pool: Array = []

	var active_count := _weapon_manager.get_active_weapon_ids().size() if _weapon_manager else 0
	var can_add_weapon := active_count < 3

	for weapon_id in WEAPON_DATA:
		if can_add_weapon and (_weapon_manager == null or not _weapon_manager.has_weapon(weapon_id)):
			pool.append({ "type": "weapon", "id": weapon_id })

	for tome_id in TOME_DATA:
		if Global.acquired_tomes.size() >= 5 and not Global.acquired_tomes.has(tome_id):
			continue
		pool.append({ "type": "tome", "id": tome_id })

	pool.shuffle()
	var selected_options = pool.slice(0, min(3, pool.size()))
	
	for opt in selected_options:
		if opt["type"] == "tome":
			opt["rarity"] = _roll_rarity()
			
	_show_cards(selected_options)

func _roll_rarity() -> Dictionary:
	var total_luck = Global.luck + (Global.items.get("old_horseshoe", 0) * 2.0)
	var roll = randf_range(0.0, 100.0 + (total_luck * 10.0))
	if roll < 51.0:
		return {"name": "Común", "mult": 1.0, "color": Color(0.6, 0.6, 0.6)}
	elif roll < 81.0:
		return {"name": "Raro", "mult": 1.2, "color": Color(0.2, 0.4, 0.8)}
	elif roll < 96.0:
		return {"name": "Épico", "mult": 1.5, "color": Color(0.6, 0.2, 0.8)}
	else:
		return {"name": "Legendario", "mult": 2.0, "color": Color(1.0, 0.8, 0.1)}

func _show_cards(options: Array):
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

	for option in options:
		hbox.add_child(_create_card(option))

	show()

func _create_card(option: Dictionary) -> Control:
	var is_weapon: bool = option["type"] == "weapon"
	var id: String = option["id"]
	var data: Dictionary = WEAPON_DATA[id] if is_weapon else TOME_DATA[id]
	var already_have := is_weapon and _weapon_manager != null and _weapon_manager.has_weapon(id)

	var panel := PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15)
	if not is_weapon and option.has("rarity"):
		style.border_color = option["rarity"]["color"]
		style.border_width_bottom = 4
		style.border_width_top = 4
		style.border_width_left = 4
		style.border_width_right = 4
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(260, 280)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var icon := ColorRect.new()
	icon.color = data["color"]
	icon.custom_minimum_size = Vector2(260, 110)
	vbox.add_child(icon)

	var name_label := Label.new()
	if is_weapon:
		name_label.text = data["name"]
	else:
		name_label.text = option["rarity"]["name"] + " " + data["name"]
		name_label.add_theme_color_override("font_color", option["rarity"]["color"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)

	var desc_label := Label.new()
	var desc_text: String = data["description"]
	
	if not is_weapon and option.has("rarity"):
		var mult: float = option["rarity"]["mult"]
		match id:
			"damage":
				desc_text = "+%d%% daño\na todas las armas." % round(10 * mult)
			"quantity":
				var q = 1.0 * mult
				desc_text = ("+%d proyectil(es)\n(no aplica al Aura)." % int(q)) if q == floor(q) else ("+%.1f proyectil(es)\n(no aplica al Aura)." % q)
			"knockback":
				desc_text = "+%d%% empuje\n(no aplica al Aura)." % round(25 * mult)
			"size":
				desc_text = "+%d%% tamaño\na todas las armas." % round(20 * mult)
			"luck":
				var l = 1.0 * mult
				desc_text = ("+%d Suerte\n(mejores rarezas)." % int(l)) if l == floor(l) else ("+%.1f Suerte\n(mejores rarezas)." % l)
			"attack_speed":
				desc_text = "+%d%% velocidad de ataque\n(no aplica al Aura)." % round(20 * mult)
			"regen":
				var r = 1.0 * mult
				desc_text = ("+%d PV/s de\nregeneración de vida." % int(r)) if r == floor(r) else ("+%.1f PV/s de\nregeneración de vida." % r)
			"proj_speed":
				desc_text = "+%d%% veloc. de proyectil\n(solo proyectiles)." % round(25 * mult)

	desc_label.text = desc_text
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	var btn := Button.new()
	btn.text = "MEJORAR" if already_have else "OBTENER"
	btn.pressed.connect(func(): _on_card_selected(option))
	vbox.add_child(btn)

	return panel

func _on_card_selected(option: Dictionary):
	if option["type"] == "weapon":
		if _weapon_manager:
			var w_data: Dictionary = WEAPON_DATA[option["id"]]
			var scene: PackedScene = load(w_data["scene_path"])
			var config: Dictionary = w_data.get("config", {})
			_weapon_manager.add_weapon(option["id"], scene, config)
	else:
		var mult = option["rarity"]["mult"] if option.has("rarity") else 1.0
		Global.apply_tome(option["id"], mult)

	for child in get_children():
		child.queue_free()
	hide()
	get_tree().paused = false
