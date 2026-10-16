extends Node3D
## Cena jogável atual: o quarto do despertar e a floresta em volta.
## Com o argumento "-- --benchmark", mede o fps num trajeto fixo e fecha.


func _enter_tree() -> void:
	InputActions.register_defaults()


func _ready() -> void:
	if "--benchmark" in OS.get_cmdline_user_args():
		var probe := Camera3D.new()
		probe.set_script(load("res://tools/fps_probe.gd"))
		add_child(probe)
