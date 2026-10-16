extends GdUnitTestSuite


func test_is_valid() -> void:
	assert_bool(SemVer.is_valid("0.1.0")).is_true()
	assert_bool(SemVer.is_valid("10.20.30")).is_true()
	assert_bool(SemVer.is_valid("1.0")).is_false()
	assert_bool(SemVer.is_valid("v1.0.0")).is_false()
	assert_bool(SemVer.is_valid("1.0.0-beta")).is_false()


func test_compare() -> void:
	assert_int(SemVer.compare("0.1.0", "0.1.0")).is_equal(0)
	assert_int(SemVer.compare("0.2.0", "0.10.0")).is_equal(-1)
	assert_int(SemVer.compare("1.0.0", "0.9.9")).is_equal(1)


func test_constraints() -> void:
	assert_bool(SemVer.is_valid_constraint(">=0.1.0")).is_true()
	assert_bool(SemVer.is_valid_constraint("0.1.0")).is_true()
	assert_bool(SemVer.is_valid_constraint("^0.1.0")).is_false()
	assert_bool(SemVer.is_valid_constraint(">=")).is_false()


func test_satisfies() -> void:
	assert_bool(SemVer.satisfies("0.1.0", ">=0.1.0")).is_true()
	assert_bool(SemVer.satisfies("0.3.2", ">=0.1.0")).is_true()
	assert_bool(SemVer.satisfies("0.1.0", ">=0.2.0")).is_false()
	assert_bool(SemVer.satisfies("0.1.0", "0.1.0")).is_true()
	assert_bool(SemVer.satisfies("0.1.1", "0.1.0")).is_false()
	assert_bool(SemVer.satisfies("lixo", ">=0.1.0")).is_false()
	assert_bool(SemVer.satisfies("0.1.0", "lixo")).is_false()
