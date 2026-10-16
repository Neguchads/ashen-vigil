extends GdUnitTestSuite


func _m(id: String, after: Array = []) -> ModManifest:
	var m := ModManifest.new()
	m.id = id
	m.load_after = PackedStringArray(after)
	return m


## Converte uma lista comum em Array[ModManifest] antes de ordenar.
func _sort(items: Array) -> ModOrder.Result:
	var typed: Array[ModManifest] = []
	typed.assign(items)
	return ModOrder.sort(typed)


func _ids(result: ModOrder.Result) -> Array[String]:
	var out: Array[String] = []
	for m in result.order:
		out.append(m.id)
	return out


func test_core_always_first() -> void:
	var r := _sort([_m("aaa"), _m("core")])
	assert_array(_ids(r)).contains_exactly(["core", "aaa"])


func test_dependencies_load_first() -> void:
	var r := _sort([_m("b", ["a"]), _m("a", ["core"]), _m("core")])
	assert_array(_ids(r)).contains_exactly(["core", "a", "b"])


func test_ties_are_alphabetical() -> void:
	var r := _sort([_m("zeta", ["core"]), _m("alpha", ["core"]), _m("core")])
	assert_array(_ids(r)).contains_exactly(["core", "alpha", "zeta"])


func test_missing_dependency_disables_in_cascade() -> void:
	var r := _sort([_m("core"), _m("a", ["ghost"]), _m("b", ["a"])])
	assert_array(_ids(r)).contains_exactly(["core"])
	assert_str(r.disabled["a"]).contains("ghost")
	assert_str(r.disabled["b"]).contains("'a'")


func test_cycle_disables_members_and_dependents() -> void:
	var r := _sort([_m("core"), _m("x", ["y"]), _m("y", ["x"]), _m("z", ["x"]), _m("ok", ["core"])])
	assert_array(_ids(r)).contains_exactly(["core", "ok"])
	assert_dict(r.disabled).contains_keys(["x", "y", "z"])
	assert_str(r.disabled["x"]).contains("ciclo")
