extends GdUnitTestSuite

const LoaderScript := preload("res://src/autoload/mod_loader.gd")
const RegistryScript := preload("res://src/autoload/content_registry.gd")
const CORE_DIR := "res://tests/fixtures/core"
const SRC := "res://tests/fixtures/mod_src"

var _loader: Node
var _registry: ContentRegistryNode
var _mods: String


func before_test() -> void:
	_loader = auto_free(LoaderScript.new())
	_registry = auto_free(RegistryScript.new())
	_mods = TestFs.make_temp_dir("test_mods")


func after_test() -> void:
	TestFs.remove_dir(_mods)


## Cria um mod instalado: mod.json + <id>.pck feito a partir de uma pasta de fixture.
func _install(id: String, src_folder: String, content: Array, load_after: Array = ["core"]) -> void:
	TestFs.write_text(
		_mods.path_join(id).path_join("mod.json"), TestFs.manifest_json(id, content, load_after)
	)
	var err := ModPacker.pack(
		SRC.path_join(src_folder).path_join("content"),
		id,
		_mods.path_join(id).path_join(id + ".pck")
	)
	assert_int(err).is_equal(OK)


func test_first_run_creates_mods_dir_and_loads_core_only() -> void:
	var missing := _mods.path_join("does_not_exist")
	var report = _loader.load_all(_registry, CORE_DIR, missing)
	assert_bool(DirAccess.dir_exists_absolute(missing)).is_true()
	assert_array(report.loaded).contains_exactly(["core"])
	assert_dict(report.disabled).is_empty()
	assert_array(report.warnings).is_empty()
	assert_bool(_registry.has_def("core:test_sword")).is_true()


func test_loads_mod_from_pck() -> void:
	_install("blade_mod", "blade_mod", ["res://mods/blade_mod/blade.tres"])
	var report = _loader.load_all(_registry, CORE_DIR, _mods)
	assert_array(report.loaded).contains_exactly(["core", "blade_mod"])
	assert_float((_registry.get_def("blade_mod:blade") as WeaponDef).damage).is_equal(30.0)
	assert_str(_registry.get_source("blade_mod:blade")).is_equal("blade_mod")


func test_mod_overrides_core_content() -> void:
	_install("override_mod", "override_mod", ["res://mods/override_mod/sword_override.tres"])
	_loader.load_all(_registry, CORE_DIR, _mods)
	assert_float((_registry.get_def("core:test_sword") as WeaponDef).damage).is_equal(99.0)
	assert_array(_registry.overrides).contains_exactly(["core:test_sword: core -> override_mod"])


func test_broken_manifest_disables_only_that_mod() -> void:
	TestFs.write_text(_mods.path_join("bad_mod").path_join("mod.json"), "{oops")
	_install("blade_mod", "blade_mod", ["res://mods/blade_mod/blade.tres"])
	var report = _loader.load_all(_registry, CORE_DIR, _mods)
	assert_str(report.disabled["bad_mod"]).contains("mod.json inválido")
	assert_array(report.loaded).contains_exactly(["core", "blade_mod"])


func test_folder_without_manifest_is_disabled() -> void:
	DirAccess.make_dir_recursive_absolute(_mods.path_join("empty_mod"))
	var report = _loader.load_all(_registry, CORE_DIR, _mods)
	assert_str(report.disabled["empty_mod"]).contains("mod.json ausente")


func test_missing_pck_disables_mod() -> void:
	TestFs.write_text(
		_mods.path_join("no_pck").path_join("mod.json"), TestFs.manifest_json("no_pck")
	)
	var report = _loader.load_all(_registry, CORE_DIR, _mods)
	assert_str(report.disabled["no_pck"]).contains("no_pck.pck ausente")


func test_bad_content_entries_warn_but_rest_loads() -> void:
	_install(
		"junk_mod",
		"junk_mod",
		["res://mods/junk_mod/ghost.tres", "res://mods/junk_mod/not_content.tres"]
	)
	_install("blade_mod", "blade_mod", ["res://mods/blade_mod/blade.tres"])
	var report = _loader.load_all(_registry, CORE_DIR, _mods)
	assert_array(report.loaded).contains_exactly(["core", "blade_mod", "junk_mod"])
	assert_int(report.warnings.size()).is_equal(2)
	assert_bool(_registry.has_def("blade_mod:blade")).is_true()


func test_dependent_of_failed_mod_is_disabled() -> void:
	TestFs.write_text(
		_mods.path_join("no_pck").path_join("mod.json"), TestFs.manifest_json("no_pck")
	)
	_install("blade_mod", "blade_mod", ["res://mods/blade_mod/blade.tres"], ["no_pck"])
	var report = _loader.load_all(_registry, CORE_DIR, _mods)
	assert_str(report.disabled["blade_mod"]).contains("no_pck")
	assert_bool(_registry.has_def("blade_mod:blade")).is_false()


func test_incompatible_game_version_is_disabled() -> void:
	TestFs.write_text(
		_mods.path_join("future_mod").path_join("mod.json"),
		TestFs.manifest_json("future_mod", [], ["core"], ">=9.0.0")
	)
	var report = _loader.load_all(_registry, CORE_DIR, _mods)
	assert_str(report.disabled["future_mod"]).contains("exige jogo >=9.0.0")


func test_core_id_is_reserved_for_user_mods() -> void:
	TestFs.write_text(
		_mods.path_join("core").path_join("mod.json"), TestFs.manifest_json("core", [], [])
	)
	var report = _loader.load_all(_registry, CORE_DIR, _mods)
	assert_str(report.disabled["core"]).contains("reservado")
	assert_array(report.loaded).contains_exactly(["core"])


func test_real_core_mod_is_valid() -> void:
	var report = _loader.load_all(_registry, "res://core", _mods)
	assert_array(report.loaded).contains_exactly(["core"])
	assert_array(report.warnings).is_empty()
	assert_bool(_registry.has_def("core:rusty_dagger")).is_true()


func test_repacking_same_virtual_path_refreshes_weapon_data() -> void:
	var source := _mods.path_join("reload_mod/content_source")
	var target := _mods.path_join("reload_mod")
	# Pasta fonte fora da busca de mods, para não virar um mod inválido.
	var content_path := "res://mods/reload_mod/blade.tres"
	TestFs.write_text(
		target.path_join("mod.json"), TestFs.manifest_json("reload_mod", [content_path])
	)
	var text := FileAccess.get_file_as_string(SRC.path_join("blade_mod/content/blade.tres"))
	text = text.replace("blade_mod:blade", "reload_mod:blade")
	TestFs.write_text(source.path_join("blade.tres"), text)
	assert_int(ModPacker.pack(source, "reload_mod", target.path_join("reload_mod.pck"))).is_equal(
		OK
	)
	_loader.load_all(_registry, CORE_DIR, _mods)
	var first := _registry.get_def("reload_mod:blade") as WeaponDef
	assert_float(first.damage).is_equal(30.0)
	TestFs.write_text(source.path_join("blade.tres"), text.replace("30.0", "77.0"))
	assert_int(ModPacker.pack(source, "reload_mod", target.path_join("reload_mod.pck"))).is_equal(
		OK
	)
	_loader.load_all(_registry, CORE_DIR, _mods)
	assert_float((_registry.get_def("reload_mod:blade") as WeaponDef).damage).is_equal(77.0)


func test_repacking_refreshes_external_weapon_scene() -> void:
	var source := _mods.path_join("model_reload/content_source")
	var target := _mods.path_join("model_reload")
	TestFs.write_text(
		target.path_join("mod.json"),
		TestFs.manifest_json("model_reload", ["res://mods/model_reload/blade.tres"])
	)
	var text := FileAccess.get_file_as_string(SRC.path_join("blade_mod/content/blade.tres"))
	text = text.replace("blade_mod:blade", "model_reload:blade")
	text = (text.replace(
		"[resource]",
		(
			'[ext_resource type="PackedScene" path="res://mods/model_reload/model.tscn" id="2"]'
			+ "\n\n[resource]"
		)
	))
	TestFs.write_text(source.path_join("blade.tres"), text + '\nscene = ExtResource("2")\n')
	var model := '[gd_scene format=3]\n[node name="Model" type="Node3D"]\nscale = Vector3(1, 1, 1)\n'
	TestFs.write_text(source.path_join("model.tscn"), model)
	(
		assert_int(ModPacker.pack(source, "model_reload", target.path_join("model_reload.pck")))
		. is_equal(OK)
	)
	_loader.load_all(_registry, CORE_DIR, _mods)
	var weapon := _registry.get_def("model_reload:blade") as WeaponDef
	var first: Node3D = auto_free(weapon.scene.instantiate())
	assert_float(first.scale.x).is_equal(1.0)
	TestFs.write_text(source.path_join("model.tscn"), model.replace("(1, 1, 1)", "(2, 2, 2)"))
	(
		assert_int(ModPacker.pack(source, "model_reload", target.path_join("model_reload.pck")))
		. is_equal(OK)
	)
	_loader.load_all(_registry, CORE_DIR, _mods)
	var reloaded := _registry.get_def("model_reload:blade") as WeaponDef
	var second: Node3D = auto_free(reloaded.scene.instantiate())
	assert_float(second.scale.x).is_equal(2.0)
