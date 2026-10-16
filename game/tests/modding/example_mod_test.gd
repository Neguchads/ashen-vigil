extends GdUnitTestSuite
## Prova o critério da spec: uma arma nova entra no jogo só pela pasta de mods.

const LoaderScript := preload("res://src/autoload/mod_loader.gd")
const RegistryScript := preload("res://src/autoload/content_registry.gd")

var _mods: String


func before_test() -> void:
	_mods = TestFs.make_temp_dir("example_mods")


func after_test() -> void:
	TestFs.remove_dir(_mods)


func test_example_weapon_mod_loads() -> void:
	var src := (
		ProjectSettings.globalize_path("res://").path_join("../mods/example_weapon").simplify_path()
	)
	var target := _mods.path_join("example_weapon")
	DirAccess.make_dir_recursive_absolute(target)
	TestFs.write_text(
		target.path_join("mod.json"), FileAccess.get_file_as_string(src.path_join("mod.json"))
	)
	(
		assert_int(
			ModPacker.pack(
				src.path_join("content"), "example_weapon", target.path_join("example_weapon.pck")
			)
		)
		. is_equal(OK)
	)

	var loader: Node = auto_free(LoaderScript.new())
	var registry: ContentRegistryNode = auto_free(RegistryScript.new())
	var report = loader.load_all(registry, "res://core", _mods)

	assert_array(report.loaded).contains_exactly(["core", "example_weapon"])
	var blade := registry.get_def("example_weapon:rusty_blade") as WeaponDef
	assert_object(blade).is_not_null()
	assert_float(blade.damage).is_equal(16.0)
