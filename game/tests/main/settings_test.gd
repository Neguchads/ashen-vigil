extends GdUnitTestSuite

const SETTINGS := preload("res://src/autoload/game_settings.gd")


func test_settings_round_trip_and_invalid_input() -> void:
	var settings: Node = auto_free(SETTINGS.new())
	var folder := TestFs.make_temp_dir("settings")
	var path := folder.path_join("settings.cfg")
	assert_bool(settings.set_option("fov", 90.0)).is_true()
	assert_bool(settings.set_option("volume", 0.4)).is_true()
	assert_bool(settings.set_option("reduced_motion", true)).is_true()
	assert_bool(settings.set_option("fov", "broken")).is_false()
	assert_bool(settings.set_option("unknown", true)).is_false()
	assert_int(settings.save_config(path)).is_equal(OK)
	var reloaded: Node = auto_free(SETTINGS.new())
	assert_int(reloaded.load_config(path)).is_equal(OK)
	assert_float(float(reloaded.values.fov)).is_equal(90.0)
	assert_float(float(reloaded.values.volume)).is_equal(0.4)
	assert_bool(reloaded.values.reduced_motion).is_true()
	TestFs.remove_dir(folder)


func test_pause_menu_freezes_world_and_restores_capture() -> void:
	var runner := scene_runner("res://src/main/main.tscn")
	var menu := runner.scene().get_node("PauseMenu")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# O backend headless pode manter o mouse visível mesmo após solicitar captura.
	var original := Input.mouse_mode
	menu.set_open(true)
	var paused := get_tree().paused
	var mouse := Input.mouse_mode
	menu.set_open(false)
	assert_bool(paused).is_true()
	assert_int(mouse).is_equal(Input.MOUSE_MODE_VISIBLE)
	assert_bool(get_tree().paused).is_false()
	assert_int(Input.mouse_mode).is_equal(original)


func test_menu_controls_apply_camera_and_graphics_settings() -> void:
	var runner := scene_runner("res://src/main/main.tscn")
	var root := runner.scene()
	var before: Dictionary = GameSettings.values.duplicate()
	var grid := root.get_node("PauseMenu/Root/Scroll/Center/Panel/Margin/Content/Settings")
	(grid.get_node("Fov") as Range).value = 90.0
	(grid.get_node("Sensitivity") as Range).value = 0.003
	(grid.get_node("Quality") as OptionButton).item_selected.emit(0)
	assert_float((root.get_node("Player/Head/Camera") as Camera3D).fov).is_equal(90.0)
	assert_float((root.get_node("Player") as Player).mouse_sensitivity).is_equal(0.003)
	var environment := (root.get_node("WorldEnvironment") as WorldEnvironment).environment
	assert_bool(environment.sdfgi_enabled).is_false()
	assert_bool(environment.volumetric_fog_enabled).is_false()
	for key: String in before:
		GameSettings.set_option(key, before[key])
