extends CanvasLayer
## Menu nativo que continua recebendo teclado enquanto o mundo está pausado.

var opened := false
var _captured_before := false
var _dead := false

@onready var _root: Control = $Root
@onready var _content: VBoxContainer = $Root/Scroll/Center/Panel/Margin/Content
@onready var _grid: GridContainer = $Root/Scroll/Center/Panel/Margin/Content/Settings
@onready var _status: Label = $Root/Scroll/Center/Panel/Margin/Content/Status
@onready var _player := get_parent().get_node("Player") as Player


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root.hide()
	_content.get_node("Resume").pressed.connect(func() -> void: set_open(false))
	_content.get_node("Actions/Save").pressed.connect(_save)
	_content.get_node("Actions/Defaults").pressed.connect(GameSettings.reset_defaults)
	_content.get_node("Footer/Restart").pressed.connect(_restart)
	_content.get_node("Footer/Quit").pressed.connect(func() -> void: get_tree().quit())
	for pair: Array in [["Sensitivity", "mouse_sensitivity"], ["Fov", "fov"], ["Volume", "volume"]]:
		var key: String = pair[1]
		(_grid.get_node(pair[0]) as Range).value_changed.connect(
			func(value: float) -> void: GameSettings.set_option(key, value)
		)
	for pair: Array in [
		["Fullscreen", "fullscreen"], ["Vsync", "vsync"], ["Motion", "reduced_motion"]
	]:
		var key: String = pair[1]
		(_grid.get_node(pair[0]) as CheckButton).toggled.connect(
			func(value: bool) -> void: GameSettings.set_option(key, value)
		)
	(_grid.get_node("Quality") as OptionButton).item_selected.connect(
		func(index: int) -> void: GameSettings.set_option("quality", index)
	)
	GameSettings.changed.connect(_refresh)
	_refresh()


func _exit_tree() -> void:
	if opened:
		get_tree().paused = false


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or event.is_echo():
		return
	if _player.reading and not opened:
		_player.close_text()
	else:
		set_open(not opened)
	get_viewport().set_input_as_handled()


func set_open(value: bool) -> void:
	if _dead and not value:
		return
	if opened == value:
		return
	opened = value
	_root.visible = value
	if value:
		_captured_before = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		# A pausa congela o ataque/esquiva; liberar o bloqueio evita uma defesa presa.
		if _player.combat.state == CombatController.State.BLOCKING:
			_player.combat.set_blocking(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		_content.get_node("Footer/Restart" if _dead else "Resume").grab_focus()
	else:
		get_tree().paused = false
		Input.mouse_mode = (
			Input.MOUSE_MODE_CAPTURED if _captured_before else Input.MOUSE_MODE_VISIBLE
		)


func show_death() -> void:
	_dead = true
	(_content.get_node("Title") as Label).text = "Você morreu"
	(_content.get_node("Subtitle") as Label).text = "O despertar ainda pode acontecer outra vez."
	(_content.get_node("Resume") as Button).disabled = true
	set_open(true)


func _restart() -> void:
	_dead = false
	set_open(false)
	get_tree().reload_current_scene()


func _save() -> void:
	var error: Error = GameSettings.save_config()
	_status.text = (
		"Configurações salvas."
		if error == OK
		else "Não foi possível salvar: " + error_string(error)
	)


func _refresh() -> void:
	var values: Dictionary = GameSettings.values
	_status.text = "Alterações aplicadas. Salve para a próxima partida."
	(_grid.get_node("FovLabel") as Label).text = "Campo de visão: %d°" % int(values.fov)
	(_grid.get_node("VolumeLabel") as Label).text = (
		"Volume geral: %d%%" % int(float(values.volume) * 100)
	)
	(_grid.get_node("Sensitivity") as Range).set_value_no_signal(float(values.mouse_sensitivity))
	(_grid.get_node("Fov") as Range).set_value_no_signal(float(values.fov))
	(_grid.get_node("Volume") as Range).set_value_no_signal(float(values.volume))
	(_grid.get_node("Fullscreen") as CheckButton).set_pressed_no_signal(values.fullscreen)
	(_grid.get_node("Vsync") as CheckButton).set_pressed_no_signal(values.vsync)
	(_grid.get_node("Motion") as CheckButton).set_pressed_no_signal(values.reduced_motion)
	(_grid.get_node("Quality") as OptionButton).select(int(values.quality))
