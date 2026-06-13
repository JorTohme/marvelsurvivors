extends CanvasLayer

const ITEM_DATA: Dictionary = {
	"lucky_coin": {
		"name": "Moneda de la Suerte",
		"description": "+2% prob. de Oro Doble (Acumulable).",
		"color": Color(1.0, 0.8, 0.2),
		"type": "stackable",
		"tier": "common"
	},
	"broken_lockpick": {
		"name": "Ganzúa Rota",
		"description": "+1% prob. de Cofre Gratis (Acumulable).",
		"color": Color(0.6, 0.6, 0.6),
		"type": "stackable",
		"tier": "common"
	},
	"backpack": {
		"name": "Mochila de Cuero",
		"description": "+1 Proyectil a todas las armas (Acumulable).",
		"color": Color(0.5, 0.3, 0.1),
		"type": "stackable",
		"tier": "rare"
	},
	"magnet_ring": {
		"name": "Anillo Magnético",
		"description": "+15% área de recolección de exp (Acumulable).",
		"color": Color(0.2, 0.9, 0.4),
		"type": "stackable",
		"tier": "rare"
	},

	"anvil": {
		"name": "Yunque Pequeño",
		"description": "+2 Daño base (Acumulable).",
		"color": Color(0.4, 0.4, 0.5),
		"type": "stackable",
		"tier": "rare"
	},
	"magnifying_glass": {
		"name": "Lente de Aumento",
		"description": "+2% prob. Crítico (Acumulable).",
		"color": Color(0.3, 0.8, 0.9),
		"type": "stackable",
		"tier": "epic"
	},
	"static_gloves": {
		"name": "Guantes de Estática",
		"description": "10% prob. de rebotar daño a enemigos cercanos (Único).",
		"color": Color(0.8, 0.2, 0.9),
		"type": "unique",
		"tier": "legendary"
	},
	"broken_mirror": {
		"name": "Espejo Roto",
		"description": "15% prob. de esquivar daño (Único).",
		"color": Color(0.8, 0.9, 1.0),
		"type": "unique",
		"tier": "legendary"
	},
	"overpowered_lamp": {
		"name": "Lámpara Sobrecargada",
		"description": "Duplica las chances de objetos únicos (Único).",
		"color": Color(1.0, 0.5, 0.0),
		"type": "unique",
		"tier": "legendary"
	},
	"lead_boots": {
		"name": "Botas de Plomo",
		"description": "Inmunidad al knockback enemigo, -5% velocidad (Único).",
		"color": Color(0.2, 0.2, 0.2),
		"type": "unique",
		"tier": "legendary"
	},
	"light_boots": {
		"name": "Botas Ligeras",
		"description": "+10% velocidad de movimiento (Acumulable).",
		"color": Color(0.4, 0.9, 0.6),
		"type": "stackable",
		"tier": "common"
	},
	"portable_battery": {
		"name": "Batería Portátil",
		"description": "+1 carga máxima para el Dash (Único).",
		"color": Color(0.1, 0.6, 1.0),
		"type": "unique",
		"tier": "legendary"
	},
	"rusty_spring": {
		"name": "Resorte Oxidado",
		"description": "+10% a la distancia y velocidad del Dash (Acumulable).",
		"color": Color(0.7, 0.5, 0.3),
		"type": "stackable",
		"tier": "rare"
	},
	"pocket_watch": {
		"name": "Reloj de Bolsillo",
		"description": "+15% tiempo de inmunidad al recibir daño (Acumulable).",
		"color": Color(0.9, 0.8, 0.5),
		"type": "stackable",
		"tier": "epic"
	},
	"overloaded_magnet": {
		"name": "Imán Sobrecargado",
		"description": "Atrae gemas perdidas fuera de pantalla (Único).",
		"color": Color(0.9, 0.1, 0.3),
		"type": "unique",
		"tier": "legendary"
	},
	"blood_pact": {
		"name": "Pacto de Sangre",
		"description": "+50% daño base, pero anula la regeneración pasiva (Único).",
		"color": Color(0.8, 0.0, 0.0),
		"type": "unique",
		"tier": "legendary"
	},
	"thorn_armor": {
		"name": "Armadura de Espinas",
		"description": "Devuelve 50% del daño recibido al atacante (Acumulable).",
		"color": Color(0.4, 0.6, 0.2),
		"type": "stackable",
		"tier": "epic"
	},
	"dirty_bandage": {
		"name": "Venda Sucia",
		"description": "+10 de Salud Máxima (Acumulable).",
		"color": Color(0.8, 0.4, 0.4),
		"type": "stackable",
		"tier": "common"
	},
	"whetstone": {
		"name": "Piedra de Afilar",
		"description": "+3% a la Velocidad de Ataque (Acumulable).",
		"color": Color(0.5, 0.5, 0.6),
		"type": "stackable",
		"tier": "common"
	},
	"light_feather": {
		"name": "Pluma Ligera",
		"description": "+5% Velocidad de Proyectiles (Acumulable).",
		"color": Color(0.9, 0.9, 0.9),
		"type": "stackable",
		"tier": "common"
	},
	"wooden_kneepad": {
		"name": "Rodillera de Madera",
		"description": "+2% de Reducción de Daño (Acumulable).",
		"color": Color(0.6, 0.4, 0.2),
		"type": "stackable",
		"tier": "common"
	},
	"old_horseshoe": {
		"name": "Herradura Vieja",
		"description": "+2 puntos a tu Suerte (Acumulable).",
		"color": Color(0.7, 0.7, 0.8),
		"type": "stackable",
		"tier": "common"
	},
	"copper_amulet": {
		"name": "Amuleto de Cobre",
		"description": "+0.2 de Regeneración Pasiva (Acumulable).",
		"color": Color(0.8, 0.6, 0.3),
		"type": "stackable",
		"tier": "common"
	},
	"boxing_glove": {
		"name": "Guante de Boxeo",
		"description": "+5% fuerza de empuje en tus ataques (Acumulable).",
		"color": Color(0.9, 0.3, 0.2),
		"type": "stackable",
		"tier": "common"
	},
	"magic_yeast": {
		"name": "Levadura Mágica",
		"description": "+5% tamaño de armas y proyectiles (Acumulable).",
		"color": Color(0.9, 0.8, 0.7),
		"type": "stackable",
		"tier": "common"
	},
	"spearhead": {
		"name": "Punta de Lanza",
		"description": "Daño Crítico +0.1x (Acumulable).",
		"color": Color(0.7, 0.7, 0.7),
		"type": "stackable",
		"tier": "common"
	},
	"student_glasses": {
		"name": "Gafas de Estudiante",
		"description": "+3% de Experiencia Recibida (Acumulable).",
		"color": Color(0.3, 0.5, 0.8),
		"type": "stackable",
		"tier": "common"
	},
	"crumpled_coupon": {
		"name": "Cupón Arrugado",
		"description": "-2% costo de los cofres (Acumulable).",
		"color": Color(0.8, 0.8, 0.6),
		"type": "stackable",
		"tier": "common"
	},
	"bat_tooth": {
		"name": "Diente de Murciélago",
		"description": "Matar tiene 1% prob. de curarte 1 PV (Acumulable).",
		"color": Color(0.9, 0.2, 0.4),
		"type": "stackable",
		"tier": "common"
	}
}


func _ready():
	layer = 15
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("chest_screen")
	hide()

func show_chest():
	get_tree().paused = true
	
	for child in get_children():
		child.queue_free()
		
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var title := Label.new()
	title.text = "ABRISTE UN COFRE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.1))
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(-400, 100)
	title.size = Vector2(800, 70)
	add_child(title)
	
	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_CENTER)
	hbox.position = Vector2(-450, -120)
	hbox.size = Vector2(900, 300)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 30)
	add_child(hbox)
	
	var available_items = []
	for item_id in ITEM_DATA:
		if ITEM_DATA[item_id]["type"] == "unique" and Global.items.has(item_id):
			continue # Ya lo tiene, no lo ofrecemos de nuevo
		available_items.append(item_id)
		
	if available_items.is_empty():
		_close()
		return
			
	var target_tier = _roll_tier()
	var tier_pool = []
	
	for item_id in available_items:
		if ITEM_DATA[item_id].get("tier", "common") == target_tier:
			tier_pool.append(item_id)
			
	if tier_pool.is_empty():
		tier_pool = available_items
		
	var chosen_item = tier_pool.pick_random()
	
	hbox.add_child(_create_card(chosen_item))
	
	show()

func _create_card(item_id: String) -> Control:
	var data: Dictionary = ITEM_DATA[item_id]
	var count: int = Global.items.get(item_id, 0)
	
	var panel := PanelContainer.new()
	var tier_name = "Común"
	var tier_color = Color(0.6, 0.6, 0.6)
	match data.get("tier", "common"):
		"common": 
			tier_name = "Común"
			tier_color = Color(0.6, 0.6, 0.6)
		"rare":
			tier_name = "Raro"
			tier_color = Color(0.2, 0.4, 0.8)
		"epic":
			tier_name = "Épico"
			tier_color = Color(0.6, 0.2, 0.8)
		"legendary":
			tier_name = "Legendario"
			tier_color = Color(1.0, 0.8, 0.1)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15)
	style.border_color = tier_color
	style.border_width_bottom = 4
	style.border_width_top = 4
	style.border_width_left = 4
	style.border_width_right = 4
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(260, 280)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	var icon_tex = _get_item_texture(item_id)
	if icon_tex:
		var tex_rect = TextureRect.new()
		tex_rect.texture = icon_tex
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.custom_minimum_size = Vector2(260, 110)
		vbox.add_child(tex_rect)
	else:
		var icon = ColorRect.new()
		icon.color = data["color"]
		icon.custom_minimum_size = Vector2(260, 110)
		vbox.add_child(icon)
	
	var name_label := Label.new()
	name_label.text = tier_name + " " + data["name"]
	if count > 0:
		name_label.text += " (x" + str(count) + ")"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", tier_color)
	vbox.add_child(name_label)
	
	var desc_label := Label.new()
	desc_label.text = data["description"]
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)
	
	var btn := Button.new()
	btn.text = "CONTINUAR"
	btn.pressed.connect(func(): _on_item_selected(item_id))
	vbox.add_child(btn)
	
	return panel

func _on_item_selected(item_id: String):
	Global.add_item(item_id)
	_close()

func _get_item_texture(item_id: String) -> Texture2D:
	var path = "res://Assets/Items/" + item_id + ".jpg"
	
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		if tex: return tex
		
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(ProjectSettings.globalize_path(path))
		if img:
			return ImageTexture.create_from_image(img)
			
	return null

func _close():
	for child in get_children():
		child.queue_free()
	hide()
	get_tree().paused = false

func _roll_tier() -> String:
	var total_luck = Global.luck + (Global.items.get("old_horseshoe", 0) * 2.0)
	var roll = randf_range(0.0, 100.0 + (total_luck * 10.0))
	if roll < 51.0: return "common"
	elif roll < 81.0: return "rare"
	elif roll < 96.0: return "epic"
	else: return "legendary"
