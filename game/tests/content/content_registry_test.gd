extends GdUnitTestSuite

const RegistryScript := preload("res://src/autoload/content_registry.gd")

var _registry: ContentRegistryNode


func before_test() -> void:
	_registry = auto_free(RegistryScript.new())


func _weapon(id: String, damage: float = 10.0) -> WeaponDef:
	var w := WeaponDef.new()
	w.id = StringName(id)
	w.damage = damage
	return w


func test_register_and_get() -> void:
	assert_bool(_registry.register(_weapon("core:dagger"), "core")).is_true()
	assert_bool(_registry.has_def("core:dagger")).is_true()
	assert_float((_registry.get_def("core:dagger") as WeaponDef).damage).is_equal(10.0)
	assert_str(_registry.get_source("core:dagger")).is_equal("core")


func test_unknown_id_returns_null() -> void:
	assert_object(_registry.get_def("core:nothing")).is_null()
	assert_str(_registry.get_source("core:nothing")).is_equal("")


func test_rejects_invalid_id() -> void:
	assert_bool(_registry.register(_weapon("dagger"), "core")).is_false()
	assert_bool(_registry.has_def("dagger")).is_false()


func test_rejects_null() -> void:
	assert_bool(_registry.register(null, "core")).is_false()


func test_later_registration_overrides_and_is_recorded() -> void:
	_registry.register(_weapon("core:dagger", 10.0), "core")
	_registry.register(_weapon("core:dagger", 99.0), "big_dagger")
	assert_float((_registry.get_def("core:dagger") as WeaponDef).damage).is_equal(99.0)
	assert_str(_registry.get_source("core:dagger")).is_equal("big_dagger")
	assert_array(_registry.overrides).contains_exactly(["core:dagger: core -> big_dagger"])


func test_list_filters_by_type_and_sorts_by_id() -> void:
	_registry.register(_weapon("core:sword"), "core")
	_registry.register(_weapon("core:axe"), "core")
	var item := ItemDef.new()
	item.id = &"core:candle"
	_registry.register(item, "core")
	var ids: Array[String] = []
	for def in _registry.list(&"weapon"):
		ids.append(String(def.id))
	assert_array(ids).contains_exactly(["core:axe", "core:sword"])
	assert_int(_registry.list(&"item").size()).is_equal(1)


func test_clear() -> void:
	_registry.register(_weapon("core:dagger"), "core")
	_registry.register(_weapon("core:dagger"), "other")
	_registry.clear()
	assert_bool(_registry.has_def("core:dagger")).is_false()
	assert_array(_registry.overrides).is_empty()
