class_name ContentSpawner
extends Node3D
## Resolve uma arma pelo ID. O modelo vem dos dados, sem caminho de arma no jogador.

const PICKUP := preload("res://src/world/weapon_pickup.tscn")

@export var content_id: StringName = &"core:rusty_dagger"


func _ready() -> void:
	var weapon := ContentRegistry.get_def(String(content_id)) as WeaponDef
	if weapon == null:
		return
	var pickup := PICKUP.instantiate() as WeaponPickup
	pickup.name = "Pickup"
	pickup.weapon = weapon
	add_child(pickup)
	var stone := CSGBox3D.new()
	stone.name = "Stone"
	stone.size = Vector3(0.8, 0.7, 0.8)
	stone.position.y = -0.4
	stone.use_collision = true
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.21, 0.23, 0.25)
	material.roughness = 1.0
	stone.material = material
	add_child(stone)
