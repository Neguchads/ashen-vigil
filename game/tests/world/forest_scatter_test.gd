extends GdUnitTestSuite

const Forest := preload("res://src/world/forest_builder.gd")


func test_trail_remains_clear_for_distant_wolf_encounter() -> void:
	var trees: Array[Transform3D] = Forest.scatter(600, 120.0, 10.0, 42, 3.5, 38.0)
	assert_int(trees.size()).is_equal(600)
	for tree in trees:
		var in_trail := absf(tree.origin.x) < 3.5 and tree.origin.z > 0.0 and tree.origin.z < 38.0
		assert_bool(in_trail).is_false()


func test_count_and_clearing() -> void:
	var trees := Forest.scatter(200, 100.0, 10.0, 7)
	assert_int(trees.size()).is_equal(200)
	for t in trees:
		assert_float(t.origin.length()).is_greater_equal(10.0)
		assert_float(absf(t.origin.x)).is_less_equal(50.0)
		assert_float(t.origin.y).is_equal(0.0)


func test_same_seed_same_forest() -> void:
	var a := Forest.scatter(50, 100.0, 10.0, 3)
	var b := Forest.scatter(50, 100.0, 10.0, 3)
	for i in 50:
		assert_vector(a[i].origin).is_equal(b[i].origin)


func test_impossible_clearing_returns_empty() -> void:
	assert_int(Forest.scatter(10, 20.0, 15.0, 1).size()).is_equal(0)
