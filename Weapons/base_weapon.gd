class_name BaseWeapon
extends Area2D

enum WeaponType { MELEE, RANGED, AURA }

@export var weapon_type: WeaponType = WeaponType.RANGED
@export var base_damage: float = 5.0

func _ready() -> void:
	Global.stats_changed.connect(_on_stats_changed)
	_on_stats_changed()

func _on_stats_changed() -> void:
	pass

func level_up() -> void:
	pass
