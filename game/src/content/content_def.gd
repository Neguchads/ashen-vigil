class_name ContentDef
extends Resource
## Base de todo conteúdo registrável. O id segue o formato "<mod>:<nome>".

const ID_PATTERN := "^[a-z0-9_]+:[a-z0-9_]+$"

static var _id_regex: RegEx

@export var id: StringName


static func is_valid_id(value: String) -> bool:
	if _id_regex == null:
		_id_regex = RegEx.create_from_string(ID_PATTERN)
	return _id_regex.search(value) != null


## Tipo usado por ContentRegistry.list(). Cada subclasse sobrescreve.
func get_content_type() -> StringName:
	return &"content"
