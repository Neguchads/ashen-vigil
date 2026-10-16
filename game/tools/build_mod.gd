extends SceneTree
## Uso: godot --headless --path game -s res://tools/build_mod.gd -- <pasta_do_mod> <pasta_de_saida>
## Gera <saida>/<id>/mod.json e <saida>/<id>/<id>.pck.


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		printerr("Uso: -- <pasta_do_mod> <pasta_de_saida>")
		quit(2)
		return
	var src: String = args[0]
	var out_root: String = args[1]
	var manifest := ModManifest.parse(
		FileAccess.get_file_as_string(src.path_join("mod.json")), src.get_file()
	)
	if manifest.error != "":
		printerr("mod.json inválido: ", manifest.error)
		quit(1)
		return
	var out_dir := out_root.path_join(manifest.id)
	if manifest.id == "core":
		printerr("O id 'core' é reservado ao jogo base.")
		quit(1)
		return
	var directory_error := DirAccess.make_dir_recursive_absolute(out_dir)
	if directory_error != OK:
		printerr("Falha ao criar saída: ", error_string(directory_error))
		quit(1)
		return
	var err := ModPacker.pack(
		src.path_join("content"), manifest.id, out_dir.path_join(manifest.id + ".pck")
	)
	if err != OK:
		printerr("Falha ao empacotar: ", error_string(err))
		quit(1)
		return
	err = DirAccess.copy_absolute(src.path_join("mod.json"), out_dir.path_join("mod.json"))
	if err != OK:
		printerr("Falha ao copiar manifesto: ", error_string(err))
		quit(1)
		return
	print("Mod gerado em ", out_dir)
	quit(0)
