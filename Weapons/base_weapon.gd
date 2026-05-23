class_name BaseWeapon
extends Area2D

enum WeaponType { MELEE, RANGED, AURA }

@export var weapon_type: WeaponType = WeaponType.RANGED
@export var base_damage: float = 5.0

func level_up() -> void:
	pass
