extends Node
## Preferências locais. Não altera os dados de conteúdo do jogo ou dos mods.

signal changed

const DEFAULTS := {
	"mouse_sensitivity": 0.0022,
	"fov": 75.0,
	"volume": 0.8,
	"fullscreen": false,
	"vsync": true,
	"quality": 2,
	"reduced_motion": false,
}

var values: Dictionary = DEFAULTS.duplicate()


func _ready() -> void:
	load_config()
	apply_runtime()


func set_option(key: String, value: Variant) -> bool:
	if not DEFAULTS.has(key):
		return false
	if key in ["fullscreen", "vsync", "reduced_motion"]:
		if not value is bool:
			return false
	elif not (value is float or value is int) or not is_finite(float(value)):
		return false
	match key:
		"mouse_sensitivity":
			value = clampf(float(value), 0.0005, 0.006)
		"fov":
			value = clampf(float(value), 60.0, 105.0)
		"volume":
			value = clampf(float(value), 0.0, 1.0)
		"quality":
			value = clampi(int(value), 0, 2)
	values[key] = value
	if is_inside_tree():
		apply_runtime()
	changed.emit()
	return true


func reset_defaults() -> void:
	values = DEFAULTS.duplicate()
	apply_runtime()
	changed.emit()


func load_config(path: String = "user://settings.cfg") -> Error:
	var config := ConfigFile.new()
	var error := config.load(path)
	if error != OK:
		return error
	for key: String in DEFAULTS:
		set_option(key, config.get_value("settings", key, DEFAULTS[key]))
	return OK


func save_config(path: String = "user://settings.cfg") -> Error:
	var config := ConfigFile.new()
	for key: String in DEFAULTS:
		config.set_value("settings", key, values[key])
	return config.save(path)


func apply_runtime() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(float(values.volume), 0.0001)))
	AudioServer.set_bus_mute(0, float(values.volume) <= 0.0)
	if DisplayServer.get_name() == "headless":
		return
	var mode := (
		DisplayServer.WINDOW_MODE_FULLSCREEN
		if values.fullscreen
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
	DisplayServer.window_set_mode(mode)
	var sync := DisplayServer.VSYNC_ENABLED if values.vsync else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(sync)


func apply_environment(environment: Environment) -> void:
	var quality := int(values.quality)
	environment.sdfgi_enabled = quality == 2
	environment.volumetric_fog_enabled = quality >= 1
