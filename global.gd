extends Node

var level: int = 1
var current_xp: int = 0
var next_level_xp: int = 100 # Meta inicial

func add_xp(amount):
	current_xp += amount
	while current_xp >= next_level_xp:
		level_up()

func level_up():
	var overflow = current_xp - next_level_xp
	
	current_xp = overflow
	
	level += 1
	next_level_xp += 50 
	
	# Opción B: Multiplicar (100 -> 120 -> 144...) (Más difícil a largo plazo)
	# next_level_xp = int(next_level_xp * 1.2)
	
	# TODO: pausar el juego para elegir mejoras...
