class_name ContentRegistryNode
extends Node
## Registro central de conteúdo: o jogo procura tudo por ID, nunca por caminho.
## O autoload se chama ContentRegistry; a classe tem outro nome para não colidir com ele.

## Substituições feitas por mods, no formato "id: mod_antigo -> mod_novo".
var overrides: Array[String] = []

var _defs: Dictionary = {}  # String -> ContentDef
var _sources: Dictionary = {}  # String -> String (mod que registrou)


func register(def: ContentDef, source_mod: String) -> bool:
	if def == null:
		push_warning("ContentRegistry: definição nula ignorada (%s)" % source_mod)
		return false
	var key := String(def.id)
	if not ContentDef.is_valid_id(key):
		push_warning("ContentRegistry: id inválido '%s' em %s" % [key, source_mod])
		return false
	if _defs.has(key):
		overrides.append("%s: %s -> %s" % [key, _sources[key], source_mod])
	_defs[key] = def
	_sources[key] = source_mod
	return true


func has_def(id: String) -> bool:
	return _defs.has(id)


func get_def(id: String) -> ContentDef:
	return _defs.get(id)


func get_source(id: String) -> String:
	return _sources.get(id, "")


func list(content_type: StringName) -> Array[ContentDef]:
	var result: Array[ContentDef] = []
	for def: ContentDef in _defs.values():
		if def.get_content_type() == content_type:
			result.append(def)
	result.sort_custom(_by_id)
	return result


static func _by_id(a: ContentDef, b: ContentDef) -> bool:
	return String(a.id) < String(b.id)


func clear() -> void:
	_defs.clear()
	_sources.clear()
	overrides.clear()
