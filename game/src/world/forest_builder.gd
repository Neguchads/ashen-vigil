extends Node3D
## Floresta em volta da casa: chão, árvores (MultiMesh) e colisão dos troncos.
## Sem modelo de árvore definido, usa uma árvore greybox (tronco e copa).

## Modelo de árvore (.glb). Vazio = árvore greybox.
@export var tree_scene: PackedScene
@export var tree_count := 600
@export var area_size := 120.0
@export var clearing_radius := 10.0
@export var scatter_seed := 42
## Material do chão. Vazio = cor de terra escura.
@export var ground_material: Material
## Corredor sem troncos até o encontro distante.
@export var trail_half_width := 3.5
@export var trail_length := 38.0

var tree_transforms: Array[Transform3D] = []


func _ready() -> void:
	tree_transforms = scatter(
		tree_count, area_size, clearing_radius, scatter_seed, trail_half_width, trail_length
	)
	_build_ground()
	_build_trees()
	_build_trunk_collision()


## Espalha `count` árvores num quadrado de lado `size`, fora de um círculo `clearing`.
## Mesma semente, mesma floresta. Clareira impossível devolve lista vazia.
static func scatter(
	count: int,
	size: float,
	clearing: float,
	seed_value: int,
	trail_width: float = 0.0,
	trail_distance: float = 0.0
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
		if absf(pos.x) < trail_width and pos.z > 0.0 and pos.z < trail_distance:
			continue
		var size_factor := rng.randf_range(0.8, 1.4)
		var tree_basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * size_factor)
		out.append(Transform3D(tree_basis, pos))
	return out


static func _flat_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	return mat


## Posição de `node` relativa a `root`, sem precisar estar na árvore de cena.
static func _relative_transform(root: Node3D, node: Node3D) -> Transform3D:
	var t := Transform3D.IDENTITY
	var current: Node = node
	while current != root and current is Node3D:
		t = (current as Node3D).transform * t
		current = current.get_parent()
	return t


func _build_ground() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(area_size, area_size)
	var mesh := MeshInstance3D.new()
	mesh.name = "GroundMesh"
	mesh.mesh = plane
	mesh.position.y = -0.01  # abaixo do piso do quarto, evita tremulação
	mesh.material_override = (
		ground_material if ground_material else _flat_material(Color(0.08, 0.07, 0.05))
	)
	add_child(mesh)
	var box := BoxShape3D.new()
	box.size = Vector3(area_size, 1.0, area_size)
	var shape := CollisionShape3D.new()
	shape.shape = box
	shape.position.y = -0.5
	var body := StaticBody3D.new()
	body.name = "Ground"
	body.add_child(shape)
	add_child(body)


## Cada parte da árvore: {"mesh": Mesh, "offset": Transform3D, "material": Material ou null}.
func _tree_parts() -> Array[Dictionary]:
	var parts: Array[Dictionary] = []
	if tree_scene == null:
		var trunk := CylinderMesh.new()
		trunk.top_radius = 0.15
		trunk.bottom_radius = 0.25
		trunk.height = 4.0
		var crown := CylinderMesh.new()
		crown.top_radius = 0.0
		crown.bottom_radius = 1.6
		crown.height = 5.0
		(
			parts
			. append(
				{
					"mesh": trunk,
					"offset": Transform3D(Basis.IDENTITY, Vector3(0, 2, 0)),
					"material": _flat_material(Color(0.12, 0.09, 0.07)),
				}
			)
		)
		(
			parts
			. append(
				{
					"mesh": crown,
					"offset": Transform3D(Basis.IDENTITY, Vector3(0, 5.5, 0)),
					"material": _flat_material(Color(0.04, 0.08, 0.05)),
				}
			)
		)
		return parts
	var root := tree_scene.instantiate() as Node3D
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		parts.append({"mesh": mi.mesh, "offset": _relative_transform(root, mi), "material": null})
	root.free()
	return parts


func _build_trees() -> void:
	for part in _tree_parts():
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = part["mesh"]
		mm.instance_count = tree_transforms.size()
		var offset: Transform3D = part["offset"]
		for i in tree_transforms.size():
			mm.set_instance_transform(i, tree_transforms[i] * offset)
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		if part["material"] != null:
			mmi.material_override = part["material"]
		add_child(mmi)


func _build_trunk_collision() -> void:
	var shape := CylinderShape3D.new()
	shape.radius = 0.3
	shape.height = 4.0
	var body := StaticBody3D.new()
	body.name = "Trunks"
	for t in tree_transforms:
		var col := CollisionShape3D.new()
		col.shape = shape
		col.position = t.origin + Vector3(0, 2, 0)
		body.add_child(col)
	add_child(body)
