extends GdUnitTestSuite


func _json(overrides: Dictionary = {}) -> String:
	var data := {
		"id": "blade_mod",
		"name": "Lâmina",
		"version": "1.0.0",
		"game_version": ">=0.1.0",
		"load_after": ["core"],
		"content": ["res://mods/blade_mod/blade.tres"],
	}
	data.merge(overrides, true)
	return JSON.stringify(data)


func test_parses_valid_manifest() -> void:
	var m := ModManifest.parse(_json(), "blade_mod")
	assert_str(m.error).is_empty()
	assert_str(m.id).is_equal("blade_mod")
	assert_str(m.display_name).is_equal("Lâmina")
	assert_str(m.version).is_equal("1.0.0")
	assert_str(m.game_version).is_equal(">=0.1.0")
	assert_array(Array(m.load_after)).contains_exactly(["core"])
	assert_array(Array(m.content)).contains_exactly(["res://mods/blade_mod/blade.tres"])


func test_optional_lists_default_to_empty() -> void:
	var data := {"id": "x", "name": "X", "version": "1.0.0", "game_version": ">=0.1.0"}
	var m := ModManifest.parse(JSON.stringify(data), "x")
	assert_str(m.error).is_empty()
	assert_array(Array(m.load_after)).is_empty()
	assert_array(Array(m.content)).is_empty()


func test_broken_json() -> void:
	var m := ModManifest.parse("{oops", "blade_mod")
	assert_str(m.error).contains("mod.json inválido")


func test_not_an_object() -> void:
	assert_str(ModManifest.parse("[1, 2]", "blade_mod").error).contains("objeto")


func test_missing_required_field() -> void:
	var data := {"id": "blade_mod", "name": "L", "game_version": ">=0.1.0"}
	assert_str(ModManifest.parse(JSON.stringify(data), "blade_mod").error).contains("'version'")


func test_id_must_match_folder() -> void:
	assert_str(ModManifest.parse(_json(), "other_folder").error).contains(
		"diferente do nome da pasta"
	)


func test_id_charset() -> void:
	var m := ModManifest.parse(_json({"id": "Blade-Mod"}), "Blade-Mod")
	assert_str(m.error).contains("inválido")


func test_bad_version() -> void:
	assert_str(ModManifest.parse(_json({"version": "1.0"}), "blade_mod").error).contains("version")


func test_bad_game_version() -> void:
	var m := ModManifest.parse(_json({"game_version": "^0.1.0"}), "blade_mod")
	assert_str(m.error).contains("game_version")


func test_load_after_must_be_string_list() -> void:
	var m := ModManifest.parse(_json({"load_after": "core"}), "blade_mod")
	assert_str(m.error).contains("load_after")


func test_content_paths_must_be_res() -> void:
	var m := ModManifest.parse(_json({"content": ["C:/evil.tres"]}), "blade_mod")
	assert_str(m.error).contains("res://")
