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
var _item_container: GridContainer
var _drawn_items: Dictionary = {}

func _ready():
	_build_weapon_slots()
	_build_tome_slots()
	
	_gold_label = Label.new()
	_gold_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_gold_label.position = Vector2(-200, 50)
	_gold_label.add_theme_font_size_override("font_size", 24)
	_gold_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	add_child(_gold_label)
	
	_item_container = GridContainer.new()
	_item_container.columns = 2
	_item_container.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_item_container.position = Vector2(-150, -200) # Un poco más arriba y a la derecha
	_item_container.add_theme_constant_override("h_separation", 15)
	_item_container.add_theme_constant_override("v_separation", 10)
	_item_container.modulate.a = 0.75 # Semitransparente como pediste
	add_child(_item_container)
	
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
	_update_item_slots()

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

func _get_item_texture(item_id: String) -> Texture2D:
	var path = "res://Assets/Items/" + item_id + ".png"
	
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		if tex: return tex
		
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(ProjectSettings.globalize_path(path))
		if img:
			return ImageTexture.create_from_image(img)
			
	return null

func _update_item_slots():
	for item_id in Global.items.keys():
		var count = Global.items[item_id]
		if count > 0:
			if not _drawn_items.has(item_id):
				var hbox = HBoxContainer.new()
				
				var tex_rect = TextureRect.new()
				tex_rect.custom_minimum_size = Vector2(32, 32)
				tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				var tex = _get_item_texture(item_id)
				if tex:
					tex_rect.texture = tex
				else:
					var rect = ColorRect.new()
					rect.color = Color(0.5, 0.5, 0.5)
					rect.custom_minimum_size = Vector2(32, 32)
					tex_rect.add_child(rect)
				hbox.add_child(tex_rect)
				
				var lbl = Label.new()
				lbl.text = "x" + str(count)
				lbl.add_theme_font_size_override("font_size", 16)
				lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
				lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				hbox.add_child(lbl)
				
				_item_container.add_child(hbox)
				_drawn_items[item_id] = {"hbox": hbox, "label": lbl}
			else:
				_drawn_items[item_id]["label"].text = "x" + str(count)
