extends Node

signal leveled_up
signal stats_changed
signal time_up

# --- SISTEMA DE XP ---
var level: int = 1
var current_xp: int = 0
var next_level_xp: int = 100

# --- MUNDO ---
const MAP_HALF_SIZE: int = 2000

# --- SISTEMA DE TIEMPO ---
var total_time: float = 600.0 # 10 minutos
var time_left: float = 0.0
var overtime: float = 0.0
var _time_up_fired: bool = false

# --- STATS DEL JUGADOR (tomos) ---
var damage_multiplier: float = 1.0
var quantity_bonus: int = 0
var knockback_multiplier: float = 1.0
var size_multiplier: float = 1.0
var crit_chance: float = 0.01

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
	current_xp += amount
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

func apply_tome(tome_id: String) -> void:
	match tome_id:
		"damage":      damage_multiplier    += 0.10
		"quantity":    quantity_bonus       += 1
		"knockback":   knockback_multiplier += 0.25
		"size":        size_multiplier      += 0.20
		"crit_chance": crit_chance          += 0.05
	stats_changed.emit()

func reset() -> void:
	level = 1
	current_xp = 0
	next_level_xp = 100
	time_left = total_time
	overtime = 0.0
	_time_up_fired = false
	damage_multiplier = 1.0
	quantity_bonus = 0
	knockback_multiplier = 1.0
	size_multiplier = 1.0
	crit_chance = 0.01
