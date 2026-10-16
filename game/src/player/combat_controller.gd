class_name CombatController
extends Node
## Um golpe por ação; o raio físico respeita paredes e o alcance da definição da arma.

enum State { IDLE, ATTACKING, BLOCKING, DODGING, DEAD }

@export var dodge_cost := 24.0
@export var dodge_duration := 0.32
@export var dodge_speed := 7.5
@export var blocked_damage_factor := 0.2
@export var block_stamina_factor := 0.75

var state := State.IDLE
var dodge_direction := Vector3.ZERO
var _remaining := 0.0
var _until_strike := 0.0
var _struck := false
var _motion: Tween
var _base_position := Vector3.ZERO
var _base_rotation := Vector3.ZERO
var _step_time := 0.0

@onready var _player := get_parent() as Player
@onready var _hand: Node3D = $"../Head/Camera/WeaponHand"


func _ready() -> void:
	_base_position = _hand.position
	_base_rotation = _hand.rotation


func _physics_process(delta: float) -> void:
	advance(delta)


func _process(delta: float) -> void:
	if state != State.IDLE or (_motion != null and _motion.is_running()):
		return
	_step_time += delta * 8.0
	var moving := minf(_player.velocity.length() / _player.walk_speed, 1.0)
	var amplitude := 0.0 if GameSettings.values.reduced_motion else 0.012 * moving
	_hand.position = (
		_base_position + Vector3(sin(_step_time) * amplitude, cos(_step_time * 2) * amplitude, 0)
	)


func can_act() -> bool:
	return not _player.reading and not get_tree().paused and not _player.vitals.is_dead()


func try_attack() -> bool:
	var weapon := _player.equipped_weapon
	if not can_act() or state != State.IDLE or weapon == null:
		return false
	if not _player.vitals.spend(weapon.stamina_cost):
		return false
	state = State.ATTACKING
	_remaining = weapon.attack_duration
	_until_strike = clampf(weapon.strike_delay, 0.0, weapon.attack_duration)
	_struck = false
	_player.vitals.recovery_blocked = true
	_animate_swing(weapon.attack_duration)
	return true


func try_dodge(direction: Vector3) -> bool:
	if not can_act() or state != State.IDLE or not _player.vitals.spend(dodge_cost):
		return false
	state = State.DODGING
	_remaining = dodge_duration
	dodge_direction = direction.normalized()
	if dodge_direction.is_zero_approx():
		dodge_direction = _player.global_basis.z.normalized()
	_player.vitals.recovery_blocked = true
	return true


func set_blocking(active: bool) -> void:
	var previous := state
	if not active and state == State.BLOCKING:
		state = State.IDLE
		_player.vitals.recovery_blocked = false
	elif active and can_act() and state == State.IDLE and _player.equipped_weapon != null:
		state = State.BLOCKING
		_player.vitals.recovery_blocked = true
	if previous != state:
		_hand.rotation = (
			_base_rotation + (Vector3(0.1, 0.0, -0.9) if state == State.BLOCKING else Vector3.ZERO)
		)


func receive_hit(amount: float, source: Vector3) -> float:
	if state == State.DEAD or state == State.DODGING:
		return 0.0
	var toward := source - _player.global_position
	toward.y = 0.0
	var forward := -_player.global_basis.z
	if state == State.BLOCKING and forward.dot(toward.normalized()) >= 0.25:
		if _player.vitals.spend(amount * block_stamina_factor):
			amount *= blocked_damage_factor
		else:
			set_blocking(false)
	return _player.vitals.take_damage(amount)


func advance(delta: float) -> void:
	if not can_act():
		return
	if state not in [State.ATTACKING, State.DODGING]:
		return
	_remaining -= delta
	if state == State.ATTACKING and not _struck:
		_until_strike -= delta
		if _until_strike <= 0.0:
			_struck = true
			_strike()
	if _remaining <= 0.0:
		state = State.IDLE
		_player.vitals.recovery_blocked = false


func stop(dead: bool = false) -> void:
	state = State.DEAD if dead else State.IDLE
	_player.vitals.recovery_blocked = dead
	if _motion != null:
		_motion.kill()
	_hand.position = _base_position
	_hand.rotation = _base_rotation


func _strike() -> void:
	var camera := _player.get_node("Head/Camera") as Camera3D
	var weapon := _player.equipped_weapon
	if weapon == null:
		return
	var origin := camera.global_position
	var end := origin - camera.global_basis.z * weapon.reach
	var query := PhysicsRayQueryParameters3D.create(origin, end, 1, [_player.get_rid()])
	var hit := _player.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.collider.has_method("take_damage"):
		hit.collider.take_damage(weapon.damage, _player.global_position)
		_player.show_notice("Acertou")


func _animate_swing(duration: float) -> void:
	if _motion != null:
		_motion.kill()
	_hand.position = _base_position
	var windup := _base_rotation + Vector3(-0.25, -0.4, -0.7)
	var finish := _base_rotation + Vector3(0.5, 0.35, 0.5)
	_motion = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_motion.tween_property(_hand, "rotation", windup, duration * 0.25).set_trans(Tween.TRANS_QUAD)
	(
		_motion
		. tween_property(_hand, "rotation", finish, duration * 0.25)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	_motion.tween_property(_hand, "rotation", _base_rotation, duration * 0.5).set_trans(
		Tween.TRANS_SINE
	)
