extends Camera3D
## Benchmark: circula a casa por 20 s, mede fps, grava em user://benchmark.txt e fecha.

const DURATION := 20.0
const RADIUS := 25.0

var _t := 0.0
var _samples: PackedFloat32Array = []


func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	current = true


func _process(delta: float) -> void:
	_t += delta
	position = Vector3(cos(_t * 0.3) * RADIUS, 1.7, sin(_t * 0.3) * RADIUS)
	look_at(Vector3(0.0, 1.5, 0.0))
	if _t > 1.0:  # o primeiro segundo é carregamento
		_samples.append(1.0 / delta)
	if _t >= DURATION:
		_finish()


func _finish() -> void:
	var sorted := _samples.duplicate()
	sorted.sort()
	var total := 0.0
	for s in _samples:
		total += s
	var text := (
		"fps_medio=%.1f fps_1pct=%.1f amostras=%d"
		% [total / _samples.size(), sorted[int(sorted.size() * 0.01)], _samples.size()]
	)
	print(text)
	var f := FileAccess.open("user://benchmark.txt", FileAccess.WRITE)
	f.store_line(text)
	f.close()
	get_tree().quit()
