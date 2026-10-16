class_name AimAt
extends Node3D
## Vira o nó para um ponto fixo ao iniciar. Útil para apontar luzes no editor
## sem calcular rotação à mão: basta editar `target` (coordenadas do nó pai).

@export var target := Vector3.ZERO


func _ready() -> void:
	var parent := get_parent_node_3d()
	var world_target := parent.to_global(target) if parent else target
	if not global_position.is_equal_approx(world_target):
		look_at(world_target)
