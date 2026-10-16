extends GdUnitTestSuite

var _light: LightSource


func before_test() -> void:
	_light = LightSource.new()
	_light.burn_time = 10.0
	add_child(_light)


func after_test() -> void:
	_light.free()


func test_starts_unlit_and_dark() -> void:
	assert_bool(_light.lit).is_false()
	assert_float(_light.light_energy).is_equal(0.0)


func test_light_turns_on() -> void:
	assert_bool(_light.light()).is_true()
	assert_bool(_light.lit).is_true()
	assert_float(_light.light_energy).is_greater(0.0)


func test_burns_out_and_cannot_relight() -> void:
	_light.light()
	_light.tick(10.5)
	assert_bool(_light.lit).is_false()
	assert_float(_light.light_energy).is_equal(0.0)
	assert_bool(_light.light()).is_false()


func test_unlit_does_not_burn_fuel() -> void:
	_light.tick(5.0)
	assert_float(_light.fuel).is_equal(10.0)


func test_flicker_stays_near_base() -> void:
	for i in 100:
		var e := LightSource.flicker_energy(1.4, i * 0.137)
		assert_float(e).is_between(1.2, 1.6)
