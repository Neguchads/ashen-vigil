class_name ModPacker
extends RefCounted
## Empacota a pasta content/ de um mod em <id>.pck, montado em res://mods/<id>/.
## Usa PCKPacker, que não exige templates de exportação.


static func pack(content_dir: String, mod_id: String, out_pck: String) -> Error:
	var files := _collect_files(content_dir, "")
	if files.is_empty():
		push_error("ModPacker: nenhum arquivo em %s" % content_dir)
		return ERR_FILE_NOT_FOUND
	DirAccess.make_dir_recursive_absolute(out_pck.get_base_dir())
	var packer := PCKPacker.new()
	var err := packer.pck_start(ProjectSettings.globalize_path(out_pck))
	if err != OK:
		return err
	for rel in files:
		var source := ProjectSettings.globalize_path(content_dir.path_join(rel))
		err = packer.add_file("res://mods/%s/%s" % [mod_id, rel], source)
		if err != OK:
			return err
	return packer.flush()


static func _collect_files(root: String, prefix: String) -> PackedStringArray:
	var out := PackedStringArray()
	var here := root if prefix == "" else root.path_join(prefix)
	for f in DirAccess.get_files_at(here):
		if f.ends_with(".import") or f.ends_with(".uid"):
			continue
		out.append(f if prefix == "" else prefix.path_join(f))
	for d in DirAccess.get_directories_at(here):
		out.append_array(_collect_files(root, d if prefix == "" else prefix.path_join(d)))
	return out
