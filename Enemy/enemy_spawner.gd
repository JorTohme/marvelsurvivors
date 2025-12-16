extends Node2D

# Esta variable aparecerá en el Inspector para que arrastres tu escena
@export var enemy_scene: PackedScene 

func _ready():
	# Conectamos la señal del timer para que avise cuando termina la cuenta
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	# 1. Crear una copia del enemigo
	var new_enemy = enemy_scene.instantiate()
	
	# 2. Calcular posición: Un círculo alrededor del jugador
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = 500 # Distancia fuera de pantalla
		var angle = randf() * TAU # Ángulo aleatorio (0 a 360)
		
		# Fórmula mágica de trigonometría para hallar el punto (x, y)
		var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
		
		new_enemy.global_position = spawn_pos
		add_child(new_enemy) # ¡Nace el enemigo!
