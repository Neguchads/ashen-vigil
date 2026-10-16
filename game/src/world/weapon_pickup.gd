class_name WeaponPickup
extends Interactable
## Coleta única; o mesmo Resource fornece nome, atributos e modelo da arma na mão.

var weapon: WeaponDef


func _ready() -> void:
	if weapon == null:
		enabled = false
		return
	prompt = "pegar " + weapon.display_name
	if weapon.scene != null and weapon.scene.can_instantiate():
		var model := weapon.scene.instantiate()
		if model is Node3D:
			(model as Node3D).rotation.x = PI / 2.0
			add_child(model)
		elif model != null:
			model.free()


func _on_interact(by: Node) -> void:
	if not by is Player or weapon == null:
		return
	(by as Player).equip_weapon(weapon)
	enabled = false
	collision_layer = 0
	hide()
