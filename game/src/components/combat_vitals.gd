class_name CombatVitals
extends Node
## Vida e stamina por ator. O atraso de recuperação também vale após bloqueios.

signal changed
signal died

@export var max_health := 100.0
@export var max_stamina := 100.0
@export var regeneration_rate := 22.0
@export var regeneration_delay := 0.8

var health := 100.0
var stamina := 100.0
var recovery_blocked := false
var _recovery_wait := 0.0


func _ready() -> void:
	reset()


func _process(delta: float) -> void:
	advance(delta)


func reset() -> void:
	health = maxf(max_health, 1.0)
	stamina = maxf(max_stamina, 0.0)
	recovery_blocked = false
	_recovery_wait = 0.0
	changed.emit()


func is_dead() -> bool:
	return health <= 0.0


func take_damage(amount: float) -> float:
	if is_dead() or not is_finite(amount) or amount <= 0.0:
		return 0.0
	var applied := minf(health, amount)
	health -= applied
	changed.emit()
	if is_dead():
		died.emit()
	return applied


func spend(amount: float) -> bool:
	if is_dead() or not is_finite(amount) or amount < 0.0 or amount > stamina:
		return false
	stamina -= amount
	_recovery_wait = regeneration_delay
	changed.emit()
	return true


func advance(delta: float) -> void:
	if is_dead() or recovery_blocked or delta <= 0.0:
		return
	var available := maxf(0.0, delta - _recovery_wait)
	_recovery_wait = maxf(0.0, _recovery_wait - delta)
	var next := minf(max_stamina, stamina + available * regeneration_rate)
	if next != stamina:
		stamina = next
		changed.emit()
