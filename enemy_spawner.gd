extends Node2D

@export var enemy_scene: PackedScene 
@export var elite_chance: float = 0.05

func _ready():
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		var distance = 1000 
		var angle = randf() * TAU 
		var group_center = player.global_position + Vector2(cos(angle), sin(angle)) * distance
		
		var group_size = randi_range(1, 4)
		
		for i in range(group_size):
			var new_enemy = enemy_scene.instantiate()
			
			var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
			new_enemy.global_position = group_center + offset
			
			if randf() < elite_chance:
				new_enemy.make_elite()
			
			add_child(new_enemy)
