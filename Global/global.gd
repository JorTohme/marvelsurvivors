extends Node

signal leveled_up 

# --- SISTEMA DE XP ---
var level: int = 1
var current_xp: int = 0
var next_level_xp: int = 100 

# --- SISTEMA DE TIEMPO ---
var total_time: float = 600.0 # 10 minutos
var time_left: float = 0.0

func _ready():
	time_left = total_time

func _process(delta):
	if time_left > 0:
		time_left -= delta
	else:
		time_left = 0

func add_xp(amount):
	current_xp += amount
	
	
	while current_xp >= next_level_xp:
		level_up()

func level_up():
	var overflow = current_xp - next_level_xp
	current_xp = overflow
	
	level += 1
	
	next_level_xp += 50 
	
	print("Nivel alcanzado: " + str(level))
	
	emit_signal("leveled_up") 

func get_time_elapsed():
	return total_time - time_left

func get_current_minute():
	return floor(get_time_elapsed() / 60.0)
