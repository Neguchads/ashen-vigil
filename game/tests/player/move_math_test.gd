extends GdUnitTestSuite


func test_forward_is_negative_z() -> void:
	var v := MoveMath.wish_velocity(Vector2(0, -1), Basis.IDENTITY, 3.0)
	assert_vector(v).is_equal_approx(Vector3(0, 0, -3), Vector3.ONE * 0.001)


func test_follows_yaw() -> void:
	var yaw := Basis(Vector3.UP, PI / 2.0)
	var v := MoveMath.wish_velocity(Vector2(0, -1), yaw, 3.0)
	assert_vector(v).is_equal_approx(Vector3(-3, 0, 0), Vector3.ONE * 0.001)


func test_diagonal_is_not_faster() -> void:
	var v := MoveMath.wish_velocity(Vector2(1, -1), Basis.IDENTITY, 3.0)
	assert_float(v.length()).is_equal_approx(3.0, 0.001)


func test_no_input_no_movement() -> void:
	assert_vector(MoveMath.wish_velocity(Vector2.ZERO, Basis.IDENTITY, 3.0)).is_equal(Vector3.ZERO)


func test_pitch_is_clamped() -> void:
	assert_float(MoveMath.clamp_pitch(3.0)).is_equal(MoveMath.MAX_PITCH)
	assert_float(MoveMath.clamp_pitch(-3.0)).is_equal(-MoveMath.MAX_PITCH)
	assert_float(MoveMath.clamp_pitch(0.5)).is_equal(0.5)
