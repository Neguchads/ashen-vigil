class_name Player
extends CharacterBody3D
## Jogador em primeira pessoa: andar, olhar, interagir, segurar a vela e ler.

@export var walk_speed := 2.6
@export var sprint_speed := 4.6
@export var mouse_sensitivity := 0.0022
@export var gravity := 9.8

var has_candle := false
var reading := false
var equipped_weapon: WeaponDef
var _notice_time := 0.0

@onready var vitals: CombatVitals = $Vitals
@onready var combat: CombatController = $Combat

@onready var _head: Node3D = $Head
@onready var _ray: RayCast3D = $Head/Camera/InteractRay
@onready var _hand_light: LightSource = $Head/Camera/HandLight
@onready var _prompt: Label = $Hud/Prompt
@onready var _reader: PanelContainer = $Hud/Reader
@onready var _reader_text: Label = $Hud/Reader/Text
@onready var _weapon_hand: Node3D = $Head/Camera/WeaponHand
@onready var _notice: Label = $Hud/Notice
@onready var _health_bar: ProgressBar = $Hud/CombatHud/Health
@onready var _stamina_bar: ProgressBar = $Hud/CombatHud/Stamina


func _ready() -> void:
	_ray.add_exception(self)
	_hand_light.visible = false
	_reader.visible = false
	_prompt.text = ""
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")
	vitals.changed.connect(_update_hud)
	vitals.died.connect(_on_died)
	GameSettings.changed.connect(_apply_settings)
	_apply_settings()
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	var captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and captured and not reading:
		var motion := event as InputEventMouseMotion
		rotate_y(-motion.relative.x * mouse_sensitivity)
		var pitch := _head.rotation.x - motion.relative.y * mouse_sensitivity
		_head.rotation.x = MoveMath.clamp_pitch(pitch)
	elif event is InputEventMouseButton and event.pressed and not captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("interact"):
		if reading:
			close_text()
		else:
			try_interact()
	elif captured and not reading:
		if event.is_action_pressed("attack"):
			combat.try_attack()
		elif event.is_action_pressed("block"):
			combat.set_blocking(true)
		elif event.is_action_released("block"):
			combat.set_blocking(false)
		elif event.is_action_pressed("dodge"):
			var direction := Input.get_vector(
				"move_left", "move_right", "move_forward", "move_back"
			)
			combat.try_dodge(MoveMath.wish_velocity(direction, global_basis, 1.0))
		elif event.is_action_pressed("toggle_candle") and has_candle:
			if _hand_light.lit:
				_hand_light.extinguish()
			else:
				_hand_light.light()


func _process(delta: float) -> void:
	_notice_time = maxf(0.0, _notice_time - delta)
	if _notice_time == 0.0:
		_notice.text = ""


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	var input := Vector2.ZERO
	if not reading and not vitals.is_dead():
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var running := Input.is_action_pressed("sprint") and not input.is_zero_approx()
	if running and not vitals.spend(delta * 7.0):
		running = false
	var speed := sprint_speed if running else walk_speed
	if combat.state == CombatController.State.BLOCKING:
		speed *= 0.45
	var wish := MoveMath.wish_velocity(input, global_basis, speed)
	if combat.state == CombatController.State.DODGING:
		wish = combat.dodge_direction * combat.dodge_speed
	velocity.x = wish.x
	velocity.z = wish.z
	move_and_slide()
	var target := current_target()
	_prompt.text = "" if target == null or reading else "[E] " + target.prompt


func current_target() -> Interactable:
	if not _ray.is_colliding():
		return null
	var hit := _ray.get_collider() as Interactable
	if hit == null or not hit.enabled:
		return null
	return hit


func try_interact() -> void:
	if reading or vitals.is_dead() or get_tree().paused:
		return
	if combat.state in [CombatController.State.ATTACKING, CombatController.State.DODGING]:
		return
	var target := current_target()
	if target != null:
		target.interact(self)


func equip_candle() -> void:
	has_candle = true
	_hand_light.visible = true
	_hand_light.light()


func equip_weapon(weapon: WeaponDef) -> void:
	if weapon == null:
		return
	equipped_weapon = weapon
	for child in _weapon_hand.get_children():
		_weapon_hand.remove_child(child)
		child.queue_free()
	if weapon.scene != null and weapon.scene.can_instantiate():
		_weapon_hand.add_child(weapon.scene.instantiate())
	_update_hud()
	show_notice(weapon.display_name)


func show_text(text: String) -> void:
	combat.stop()
	reading = true
	_reader_text.text = text
	_reader.visible = true


func close_text() -> void:
	reading = false
	_reader.visible = false


func take_damage(amount: float, source: Vector3) -> float:
	var applied := combat.receive_hit(amount, source)
	if applied > 0.0:
		show_notice("Ferido: -%d" % int(applied))
	return applied


func show_notice(text: String) -> void:
	_notice.text = text
	_notice_time = 2.5


func _update_hud() -> void:
	_health_bar.max_value = vitals.max_health
	_health_bar.value = vitals.health
	_stamina_bar.max_value = vitals.max_stamina
	_stamina_bar.value = vitals.stamina
	($Hud/CombatHud as Control).visible = (
		equipped_weapon != null or vitals.health < vitals.max_health
	)


func _apply_settings() -> void:
	mouse_sensitivity = float(GameSettings.values.mouse_sensitivity)
	($Head/Camera as Camera3D).fov = float(GameSettings.values.fov)


func _on_died() -> void:
	combat.stop(true)
	var menu := get_parent().get_node_or_null("PauseMenu")
	if menu != null:
		menu.show_death()
