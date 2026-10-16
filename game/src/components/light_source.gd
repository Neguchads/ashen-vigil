class_name LightSource
extends OmniLight3D
## Vela ou tocha: acende, apaga, tremula e queima até acabar.

@export var base_energy := 1.4
## Segundos de chama até apagar sozinha.
@export var burn_time := 600.0

var lit := false
var fuel := 0.0

var _t := 0.0


func _ready() -> void:
	fuel = burn_time
	_apply()


func _process(delta: float) -> void:
	tick(delta)


## Acende se ainda houver combustível. Devolve se acendeu.
func light() -> bool:
	if fuel <= 0.0:
		return false
	lit = true
	_apply()
	return true


func extinguish() -> void:
	lit = false
	_apply()


## Avança o tempo da chama. Separado de _process para os testes controlarem o tempo.
func tick(delta: float) -> void:
	if not lit:
		return
	_t += delta
	fuel = maxf(fuel - delta, 0.0)
	if fuel == 0.0:
		extinguish()
		return
	light_energy = flicker_energy(base_energy, _t)


## Duas senoides fora de fase imitam o tremor de uma chama.
static func flicker_energy(base: float, t: float) -> float:
	return base + sin(t * 13.0) * 0.12 + sin(t * 7.3) * 0.08


func _apply() -> void:
	light_energy = base_energy if lit else 0.0
