class_name ModOrder
extends RefCounted
## Ordena mods por load_after. Dependência ausente ou ciclo desativa o mod (e quem depende dele).

const CORE_ID := "core"


class Result:
	var order: Array[ModManifest] = []
	var disabled: Dictionary = {}  # id -> motivo


static func sort(manifests: Array[ModManifest]) -> Result:
	var result := Result.new()
	var active: Dictionary = {}
	for m in manifests:
		active[m.id] = m

	# 1. Dependência ausente, repetido até estabilizar (cascata).
	var changed := true
	while changed:
		changed = false
		for id: String in active.keys():
			var m: ModManifest = active[id]
			for dep in m.load_after:
				if not active.has(dep):
					result.disabled[id] = "depende de '%s', que não está ativo" % dep
					active.erase(id)
					changed = true
					break

	# 2. Ordenação topológica em lotes; cada lote em ordem alfabética, com core na frente.
	var remaining: Dictionary = active.duplicate()
	while not remaining.is_empty():
		var ready: Array[String] = []
		for id: String in remaining.keys():
			var waiting := false
			for dep in (remaining[id] as ModManifest).load_after:
				if remaining.has(dep):
					waiting = true
					break
			if not waiting:
				ready.append(id)
		if ready.is_empty():
			for id: String in remaining.keys():
				result.disabled[id] = "ciclo em load_after (ou depende de um mod em ciclo)"
			break
		ready.sort()
		if ready.has(CORE_ID):
			ready.erase(CORE_ID)
			ready.push_front(CORE_ID)
		for id in ready:
			result.order.append(remaining[id])
			remaining.erase(id)
	return result
