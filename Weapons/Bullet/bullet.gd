extends Area2D

var is_aura: bool = true
var is_melee: bool = false

@export_category("Estadísticas Aura")
@export var damage: int = 5
@export var tick_rate: float = 1.0

var targets_inside: Array = []
var tick_timer: Timer

func _ready():
	tick_timer = Timer.new()
	tick_timer.wait_time = tick_rate
	tick_timer.autostart = true
	tick_timer.one_shot = false
	add_child(tick_timer)
	tick_timer.timeout.connect(_on_tick_damage)
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area):
	if area.has_method("take_damage"):
		targets_inside.append(area)
		area.take_damage(damage)

func _on_area_exited(area):
	if area in targets_inside:
		targets_inside.erase(area)

func _on_tick_damage():
	for i in range(targets_inside.size() - 1, -1, -1):
		var target = targets_inside[i]
		
		if is_instance_valid(target):
			target.take_damage(damage)
		else:
			targets_inside.remove_at(i)

func level_up_aura():
	damage += 2
	scale *= 1.1
	print("Aura subió de nivel! Daño: ", damage)
