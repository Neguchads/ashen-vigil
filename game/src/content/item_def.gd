class_name ItemDef
extends ContentDef
## Qualquer coisa que o jogador pode carregar.

@export var display_name: String = ""
@export_multiline var description: String = ""


func get_content_type() -> StringName:
	return &"item"
