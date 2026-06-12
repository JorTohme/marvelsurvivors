extends Node

signal leveled_up
signal stats_changed
signal time_up
signal gold_changed

# --- SISTEMA DE XP ---
var level: int = 1
var current_xp: int = 0
var next_level_xp: int = 100

# --- MUNDO ---
const MAP_HALF_SIZE: int = 10000

# --- SISTEMA DE TIEMPO ---
var total_time: float = 600.0 # 10 minutos
var time_left: float = 0.0
var overtime: float = 0.0
var _time_up_fired: bool = false

# --- STATS DEL JUGADOR (tomos) ---
var damage_multiplier: float = 1.0
var quantity_bonus: float = 0.0
var knockback_multiplier: float = 1.0
var size_multiplier: float = 1.0
var projectile_speed_multiplier: float = 1.0
var acquired_tomes: Array = []
var jump_count: int = 1
var jump_distance: float = 1.0
var crit_chance: float = 0.01
var attack_speed_multiplier: float = 1.0
var luck: float = 0.0
var hp_regen: float = 0.2

# --- SISTEMA DE ORO Y COFRES ---
var gold: int = 0
var chests_opened: int = 0
var items: Dictionary = {}

func add_gold(amount: int) -> void:
	# Si tiene la moneda de la suerte, tiene X% chance de oro doble
	var double_chance = items.get("lucky_coin", 0) * 0.02
	if randf() < double_chance:
		amount *= 2
	gold += amount
	gold_changed.emit()

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit()
		return true
	return false

func get_chest_cost() -> int:
	var base = 8.0
	var multiplier = pow(1.6, chests_opened)
	var total = base * multiplier
	var discount = 1.0 - min(0.9, items.get("crumpled_coupon", 0) * 0.02)
	return max(1, int(total * discount))

func add_item(item_id: String) -> void:
	if items.has(item_id):
		items[item_id] += 1
	else:
		items[item_id] = 1
	stats_changed.emit()

func roll_crit() -> bool:
	return randf() < crit_chance

func _ready():
	time_left = total_time

func _process(delta):
	if time_left > 0:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			if not _time_up_fired:
				_time_up_fired = true
				time_up.emit()
	else:
		overtime += delta

func add_xp(amount):
	var bonus = 1.0 + (items.get("student_glasses", 0) * 0.03)
	current_xp += int(amount * bonus)
	while current_xp >= next_level_xp:
		level_up()

func level_up():
	var overflow = current_xp - next_level_xp
	current_xp = overflow
	level += 1
	next_level_xp += 50
	emit_signal("leveled_up")
	AudioManager.play_sfx("level_up")

func get_time_elapsed():
	return total_time - time_left

func get_current_minute():
	return floor(get_time_elapsed() / 60.0)

func apply_tome(tome_id: String, rarity_multiplier: float = 1.0) -> void:
	if not acquired_tomes.has(tome_id):
		acquired_tomes.append(tome_id)
		
	match tome_id:
		"damage":      damage_multiplier    += 0.10 * rarity_multiplier
		"quantity":    quantity_bonus       += 1.0 * rarity_multiplier
		"knockback":   knockback_multiplier += 0.25 * rarity_multiplier
		"size":        size_multiplier      += 0.20 * rarity_multiplier
		"crit_chance": crit_chance          += 0.05 * rarity_multiplier
		"luck":        luck                 += 1.0 * rarity_multiplier
		"attack_speed": attack_speed_multiplier += 0.20 * rarity_multiplier
		"proj_speed":  projectile_speed_multiplier += 0.25 * rarity_multiplier
		"regen":       hp_regen             += 1.0 * rarity_multiplier
	stats_changed.emit()

func reset() -> void:
	level = 1
	current_xp = 0
	next_level_xp = 100
	time_left = total_time
	overtime = 0.0
	_time_up_fired = false
	damage_multiplier = 1.0
	quantity_bonus = 0.0
	knockback_multiplier = 1.0
	size_multiplier = 1.0
	projectile_speed_multiplier = 1.0
	crit_chance = 0.01
	luck = 0.0
	attack_speed_multiplier = 1.0
	hp_regen = 0.2
	acquired_tomes.clear()
	gold = 0
	chests_opened = 0
	items.clear()
