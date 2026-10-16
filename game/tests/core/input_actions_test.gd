extends GdUnitTestSuite


func test_registers_all_actions() -> void:
	InputActions.register_defaults()
	for action: String in InputActions.DEFAULTS:
		assert_bool(InputMap.has_action(action)).is_true()


func test_is_idempotent() -> void:
	InputActions.register_defaults()
	InputActions.register_defaults()
	assert_int(InputMap.action_get_events("interact").size()).is_equal(1)


func test_interact_is_e() -> void:
	InputActions.register_defaults()
	var ev := InputMap.action_get_events("interact")[0] as InputEventKey
	assert_int(ev.physical_keycode).is_equal(KEY_E)
