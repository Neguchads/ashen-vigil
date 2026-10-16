extends Interactable
## Carta que o jogador lê. O texto fica na cena e é editável no painel.

@export_multiline var text := ""


func _on_interact(by: Node) -> void:
	if by.has_method("show_text"):
		by.show_text(text)
