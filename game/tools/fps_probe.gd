extends Camera3D
## Benchmark: circula a casa por 20 s, mede fps e o tempo de CPU e GPU por quadro,
## grava em user://benchmark.txt e fecha.

const DURATION := 20.0
const RADIUS := 25.0

var _t := 0.0
var _samples: PackedFloat32Array = []
var _cpu_ms := 0.0
var _gpu_ms := 0.0
var _timed := 0


func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
	current = true


func _process(delta: float) -> void:
	_t += delta
	position = Vector3(cos(_t * 0.3) * RADIUS, 1.7, sin(_t * 0.3) * RADIUS)
	look_at(Vector3(0.0, 1.5, 0.0))
	if _t > 1.0:  # o primeiro segundo é carregamento
		_samples.append(1.0 / delta)
		var rid := get_viewport().get_viewport_rid()
		_cpu_ms += RenderingServer.viewport_get_measured_render_time_cpu(rid)
		_cpu_ms += RenderingServer.get_frame_setup_time_cpu()
		_gpu_ms += RenderingServer.viewport_get_measured_render_time_gpu(rid)
		_timed += 1
	if _t >= DURATION:
		_finish()


func _finish() -> void:
	var sorted := _samples.duplicate()
	sorted.sort()
	var total := 0.0
	for s in _samples:
		total += s
	var text := (
		"fps_medio=%.1f fps_1pct=%.1f amostras=%d render_cpu_ms=%.2f gpu_ms=%.2f"
		% [
			total / _samples.size(),
			sorted[int(sorted.size() * 0.01)],
			_samples.size(),
			_cpu_ms / maxi(_timed, 1),
			_gpu_ms / maxi(_timed, 1),
		]
	)
	print(text)
	var f := FileAccess.open("user://benchmark.txt", FileAccess.WRITE)
	f.store_line(text)
	f.close()
	get_tree().quit()
