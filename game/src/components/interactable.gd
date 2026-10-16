class_name Interactable
extends StaticBody3D
## Algo que o jogador usa olhando para ele e apertando E.
## Subclasses sobrescrevem _on_interact.

signal interacted(by: Node)

## Texto mostrado na mira, depois de "[E]".
@export var prompt := "usar"
@export var enabled := true


func interact(by: Node) -> void:
	if not enabled:
		return
	interacted.emit(by)
	_on_interact(by)


func _on_interact(_by: Node) -> void:
	pass
