extends Node3D
## Cena jogável atual: o quarto do despertar e a floresta em volta.
## Com o argumento "-- --benchmark", mede o fps num trajeto fixo e fecha.

## Área de demonstração dos mods, ao lado da adaga, antes do combate entrar no jogo.
@export var mod_weapon_spacing := 1.6


func _enter_tree() -> void:
	InputActions.register_defaults()


func _ready() -> void:
	var world := $WorldEnvironment as WorldEnvironment
	world.environment = world.environment.duplicate() as Environment
	GameSettings.changed.connect(_apply_settings)
	_apply_settings()
	var display := $ModWeapons as Node3D
	for definition in ContentRegistry.list(&"weapon"):
		if String(definition.id).begins_with("core:"):
			continue
		var spawner := ContentSpawner.new()
		spawner.content_id = definition.id
		spawner.position.x = display.get_child_count() * mod_weapon_spacing
		display.add_child(spawner)
	if "--benchmark" in OS.get_cmdline_user_args():
		var probe := Camera3D.new()
		probe.set_script(load("res://tools/fps_probe.gd"))
		add_child(probe)


func _apply_settings() -> void:
	GameSettings.apply_environment(($WorldEnvironment as WorldEnvironment).environment)
