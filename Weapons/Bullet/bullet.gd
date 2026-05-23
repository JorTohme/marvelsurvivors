class_name BulletWeapon
extends BaseWeapon

@export var speed: float = 600.0
@export var lifetime: float = 1.5

var direction: Vector2 = Vector2.RIGHT

func _init():
	weapon_type = BaseWeapon.WeaponType.RANGED

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(base_damage, global_position)
		queue_free()
