class_name BaseWeapon
extends Area2D

enum WeaponType { MELEE, RANGED, AURA }

@export var weapon_type: WeaponType = WeaponType.RANGED
@export var base_damage: float = 5.0
@export var spawn_in_line: bool = false
@export var line_spacing_delay: float = 0.1

func _ready() -> void:
	Global.stats_changed.connect(_on_stats_changed)
	_on_stats_changed()

func _on_stats_changed() -> void:
	pass

func level_up() -> void:
	pass

func get_total_damage(is_crit: bool) -> float:
	var flat_bonus = Global.items.get("anvil", 0) * 2.0
	var final_base = base_damage + flat_bonus
	var crit_mult = 2.0 + (Global.items.get("spearhead", 0) * 0.1)
	var total = final_base * Global.damage_multiplier * (crit_mult if is_crit else 1.0)
	if Global.items.has("blood_pact"):
		total *= 1.5
	return total
