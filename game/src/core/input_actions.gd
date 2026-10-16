class_name InputActions
extends RefCounted
## Teclas padrão do jogo. Ficam no código para testes e mods usarem os mesmos nomes.

const DEFAULTS := {
	"move_forward": KEY_W,
	"move_back": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"sprint": KEY_SHIFT,
	"interact": KEY_E,
	"dodge": KEY_SPACE,
	"toggle_candle": KEY_F,
}

const MOUSE_DEFAULTS := {"attack": MOUSE_BUTTON_LEFT, "block": MOUSE_BUTTON_RIGHT}


static func register_defaults() -> void:
	for action: String in DEFAULTS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = DEFAULTS[action]
		InputMap.action_add_event(action, ev)
	for action: String in MOUSE_DEFAULTS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_DEFAULTS[action]
		InputMap.action_add_event(action, ev)
