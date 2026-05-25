class_name WeaponManager
extends Node2D

@export var controller_scene: PackedScene  # arrastrá WeaponController.tscn acá

var _weapons: Dictionary = {}

func _ready():
	add_to_group("weapon_manager")
	_register_existing_controllers()

func _register_existing_controllers() -> void:
	for child in get_children():
		var scene: PackedScene = child.get("weapon_scene")
		if scene == null:
			continue
		var id := scene.resource_path.get_file().get_basename().to_lower()
		_weapons[id] = child

func add_weapon(weapon_id: String, weapon_scene: PackedScene, config: Dictionary = {}) -> void:
	if _weapons.has(weapon_id):
		_weapons[weapon_id].level_up()
		return

	if not controller_scene:
		push_error("WeaponManager: controller_scene no está asignado.")
		return

	var controller = controller_scene.instantiate()
	controller.weapon_scene = weapon_scene

	if config.has("cooldown"):
		controller.cooldown = config["cooldown"]
	if config.has("projectile_count"):
		controller.projectile_count = config["projectile_count"]
	if config.has("spread_degrees"):
		controller.spread_degrees = config["spread_degrees"]

	add_child(controller)
	_weapons[weapon_id] = controller

func level_up_weapon(weapon_id: String) -> void:
	if _weapons.has(weapon_id):
		_weapons[weapon_id].level_up()

func has_weapon(weapon_id: String) -> bool:
	return _weapons.has(weapon_id)

func get_active_weapon_ids() -> Array:
	return _weapons.keys()
