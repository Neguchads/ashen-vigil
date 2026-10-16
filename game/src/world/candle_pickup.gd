extends Interactable
## Vela sobre a mesa. Ao pegar, vai para a mão do jogador já acesa.


func _on_interact(by: Node) -> void:
	if not by.has_method("equip_candle"):
		return
	by.equip_candle()
	enabled = false
	collision_layer = 0
	hide()
