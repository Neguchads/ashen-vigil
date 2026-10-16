extends Interactable
## Conversa curta com um modelo animado; sem sistema de diálogo adicional.

@export_multiline var text := "Vi um lobo caído na trilha, depois das árvores. Ele ainda respira."


func _ready() -> void:
	var players := $Model.find_children("*", "AnimationPlayer", true, false)
	if not players.is_empty():
		var animations := players[0] as AnimationPlayer
		if animations.has_animation("Idle"):
			animations.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
			animations.play("Idle")


func _on_interact(by: Node) -> void:
	if by is Player:
		(by as Player).show_text(text)
