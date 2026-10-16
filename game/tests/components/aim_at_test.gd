extends GdUnitTestSuite

var _parent: Node3D


func before_test() -> void:
	_parent = Node3D.new()
	add_child(_parent)


func after_test() -> void:
	_parent.free()


func _aim(from: Vector3, target: Vector3) -> AimAt:
	var aim := AimAt.new()
	aim.position = from
	aim.target = target
	_parent.add_child(aim)  # _ready roda aqui
	return aim


func test_points_forward_axis_at_target() -> void:
	var aim := _aim(Vector3.ZERO, Vector3(5, 0, 0))
	var forward := -aim.global_basis.z
	assert_vector(forward).is_equal_approx(Vector3(1, 0, 0), Vector3.ONE * 0.001)


func test_target_is_relative_to_parent() -> void:
	_parent.position = Vector3(10, 0, 0)
	var aim := _aim(Vector3.ZERO, Vector3(0, 0, -3))
	var forward := -aim.global_basis.z
	assert_vector(forward).is_equal_approx(Vector3(0, 0, -1), Vector3.ONE * 0.001)


func test_target_on_itself_does_not_break() -> void:
	var aim := _aim(Vector3(1, 1, 1), Vector3(1, 1, 1))
	assert_vector(aim.rotation).is_equal(Vector3.ZERO)
