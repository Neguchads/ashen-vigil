extends Node3D
## Floresta em volta da casa: chão, árvores (MultiMesh) e colisão dos troncos.
## Sem modelo de árvore definido, usa uma árvore greybox (tronco e copa).


## Espalha `count` árvores num quadrado de lado `size`, fora de um círculo `clearing`.
## Mesma semente, mesma floresta. Clareira impossível devolve lista vazia.
static func scatter(
	count: int, size: float, clearing: float, seed_value: int
) -> Array[Transform3D]:
	var out: Array[Transform3D] = []
	var half := size / 2.0
	if clearing >= half:
		push_warning("Floresta: clareira de %.1f não cabe numa área de %.1f" % [clearing, size])
		return out
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	while out.size() < count:
		var pos := Vector3(rng.randf_range(-half, half), 0.0, rng.randf_range(-half, half))
		if pos.length() < clearing:
			continue
		var size_factor := rng.randf_range(0.8, 1.4)
		var tree_basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * size_factor)
		out.append(Transform3D(tree_basis, pos))
	return out
