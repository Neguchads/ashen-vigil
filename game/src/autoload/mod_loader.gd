extends Node
## Carrega o "mod zero" (core) e os mods do jogador, nessa ordem.
## Mod com problema é desativado com motivo; o jogo nunca fecha por causa de mod.

const CORE_DIR := "res://core"
const USER_MODS_DIR := "user://mods"
const CORE_ID := "core"


class Report:
	var loaded: Array[String] = []
	var disabled: Dictionary = {}  # pasta ou id -> motivo
	var warnings: Array[String] = []


var last_report: Report


func _ready() -> void:
	last_report = load_all(ContentRegistry, CORE_DIR, USER_MODS_DIR)
	for w in last_report.warnings:
		push_warning(w)
	for id: String in last_report.disabled:
		push_warning("Mod '%s' desativado: %s" % [id, last_report.disabled[id]])


func load_all(registry: ContentRegistryNode, core_dir: String, mods_dir: String) -> Report:
	var report := Report.new()
	var game_version: String = ProjectSettings.get_setting("application/config/version", "0.0.0")

	var core := _read_manifest(core_dir.path_join("mod.json"), CORE_ID)
	if core.error != "":
		report.disabled[CORE_ID] = core.error
		report.warnings.append("core inválido: " + core.error)
		return report
	var manifests: Array[ModManifest] = [core]

	if not DirAccess.dir_exists_absolute(mods_dir):
		DirAccess.make_dir_recursive_absolute(mods_dir)
	for folder in DirAccess.get_directories_at(mods_dir):
		var m := _read_manifest(mods_dir.path_join(folder).path_join("mod.json"), folder)
		if m.error == "" and m.id == CORE_ID:
			m.error = "o id 'core' é reservado ao jogo base"
		if m.error == "" and not SemVer.satisfies(game_version, m.game_version):
			m.error = "exige jogo %s; versão atual %s" % [m.game_version, game_version]
		if m.error != "":
			report.disabled[folder] = m.error
			continue
		manifests.append(m)

	var sorted := ModOrder.sort(manifests)
	report.disabled.merge(sorted.disabled)
	for m in sorted.order:
		var failed_dep := _first_missing_dependency(m, report.loaded)
		if failed_dep != "":
			report.disabled[m.id] = "depende de '%s', que falhou ao carregar" % failed_dep
			continue
		if m.id != CORE_ID and not _mount(m, mods_dir, report):
			continue
		_register_content(registry, m, report)
		report.loaded.append(m.id)
	return report


func _read_manifest(path: String, folder: String) -> ModManifest:
	if not FileAccess.file_exists(path):
		var missing := ModManifest.new()
		missing.error = "mod.json ausente"
		return missing
	return ModManifest.parse(FileAccess.get_file_as_string(path), folder)


func _first_missing_dependency(m: ModManifest, loaded: Array[String]) -> String:
	for dep in m.load_after:
		if not loaded.has(dep):
			return dep
	return ""


func _mount(m: ModManifest, mods_dir: String, report: Report) -> bool:
	var pck := mods_dir.path_join(m.id).path_join(m.id + ".pck")
	if not FileAccess.file_exists(pck):
		report.disabled[m.id] = "arquivo %s.pck ausente" % m.id
		return false
	if not ProjectSettings.load_resource_pack(ProjectSettings.globalize_path(pck), true):
		report.disabled[m.id] = "falha ao montar %s.pck" % m.id
		return false
	return true


func _register_content(registry: ContentRegistryNode, m: ModManifest, report: Report) -> void:
	for path in m.content:
		if not ResourceLoader.exists(path):
			report.warnings.append("%s: arquivo %s não existe" % [m.id, path])
			continue
		# Um pack pode trocar um arquivo que já está no cache do Godot.
		var res := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
		if not (res is ContentDef):
			report.warnings.append("%s: %s não é uma definição de conteúdo" % [m.id, path])
			continue
		if not registry.register(res, m.id):
			report.warnings.append("%s: id inválido em %s" % [m.id, path])
