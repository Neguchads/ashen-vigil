class_name ModManifest
extends RefCounted
## Conteúdo validado de um mod.json. Se algo estiver errado, `error` explica o quê.

const MOD_ID_PATTERN := "^[a-z0-9_]+$"

var id := ""
var display_name := ""
var version := ""
var game_version := ""
var load_after := PackedStringArray()
var content := PackedStringArray()
## Vazio quando o manifesto é válido.
var error := ""


static func parse(text: String, folder_name: String) -> ModManifest:
	var m := ModManifest.new()
	var json := JSON.new()
	if json.parse(text) != OK:
		m.error = (
			"mod.json inválido (linha %d): %s" % [json.get_error_line(), json.get_error_message()]
		)
		return m
	if typeof(json.data) != TYPE_DICTIONARY:
		m.error = "mod.json precisa ser um objeto { ... }"
		return m
	var data: Dictionary = json.data
	for key: String in ["id", "name", "version", "game_version"]:
		if typeof(data.get(key)) != TYPE_STRING:
			m.error = "campo '%s' ausente ou não é texto" % key
			return m
	m.id = data["id"]
	m.display_name = data["name"]
	m.version = data["version"]
	m.game_version = data["game_version"]

	if RegEx.create_from_string(MOD_ID_PATTERN).search(m.id) == null:
		m.error = "id '%s' inválido: use só letras minúsculas, números e _" % m.id
	elif m.id != folder_name:
		m.error = "id '%s' diferente do nome da pasta '%s'" % [m.id, folder_name]
	elif not SemVer.is_valid(m.version):
		m.error = "version '%s' inválida: use X.Y.Z" % m.version
	elif not SemVer.is_valid_constraint(m.game_version):
		m.error = "game_version '%s' inválida: use >=X.Y.Z ou X.Y.Z" % m.game_version
	if m.error != "":
		return m

	var after: Variant = _string_list(data.get("load_after", []))
	if after == null:
		m.error = "load_after precisa ser uma lista de textos"
		return m
	m.load_after = after

	var paths: Variant = _string_list(data.get("content", []))
	if paths == null:
		m.error = "content precisa ser uma lista de textos"
		return m
	for path: String in paths:
		if not path.begins_with("res://"):
			m.error = "content: '%s' precisa começar com res://" % path
			return m
	m.content = paths
	return m


## Devolve PackedStringArray ou null se `value` não for uma lista só de textos.
static func _string_list(value: Variant) -> Variant:
	if typeof(value) != TYPE_ARRAY:
		return null
	var out := PackedStringArray()
	for item: Variant in value:
		if typeof(item) != TYPE_STRING:
			return null
		out.append(item)
	return out
