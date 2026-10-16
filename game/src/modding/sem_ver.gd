class_name SemVer
extends RefCounted
## Versões MAJOR.MINOR.PATCH e restrições simples: ">=X.Y.Z" ou "X.Y.Z" (exata).

static var _regex: RegEx


static func _parse(text: String) -> PackedInt32Array:
	if _regex == null:
		_regex = RegEx.create_from_string("^(\\d+)\\.(\\d+)\\.(\\d+)$")
	var m := _regex.search(text.strip_edges())
	if m == null:
		return PackedInt32Array()
	return PackedInt32Array(
		[m.get_string(1).to_int(), m.get_string(2).to_int(), m.get_string(3).to_int()]
	)


static func is_valid(text: String) -> bool:
	return _parse(text).size() == 3


## Exige versões válidas (conferir com is_valid antes).
static func compare(a: String, b: String) -> int:
	var va := _parse(a)
	var vb := _parse(b)
	for i in 3:
		if va[i] != vb[i]:
			return -1 if va[i] < vb[i] else 1
	return 0


static func is_valid_constraint(constraint: String) -> bool:
	var c := constraint.strip_edges()
	if c.begins_with(">="):
		return is_valid(c.substr(2))
	return is_valid(c)


static func satisfies(version: String, constraint: String) -> bool:
	if not is_valid(version) or not is_valid_constraint(constraint):
		return false
	var c := constraint.strip_edges()
	if c.begins_with(">="):
		return compare(version, c.substr(2)) >= 0
	return compare(version, c) == 0
