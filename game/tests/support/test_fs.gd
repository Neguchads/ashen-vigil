class_name TestFs
extends RefCounted
## Funções de arquivo para os testes: pastas temporárias e escrita de texto.


static func make_temp_dir(prefix: String) -> String:
	var path := "user://%s_%d" % [prefix, Time.get_ticks_usec()]
	DirAccess.make_dir_recursive_absolute(path)
	return path


static func remove_dir(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	for f in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(f))
	for d in DirAccess.get_directories_at(path):
		remove_dir(path.path_join(d))
	DirAccess.remove_absolute(path)


static func write_text(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


static func manifest_json(
	id: String, content: Array = [], load_after: Array = ["core"], game_version: String = ">=0.1.0"
) -> String:
	return (
		JSON
		. stringify(
			{
				"id": id,
				"name": id,
				"version": "1.0.0",
				"game_version": game_version,
				"load_after": load_after,
				"content": content,
			}
		)
	)
