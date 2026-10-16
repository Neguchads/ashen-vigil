class_name Player
extends CharacterBody3D
## Jogador em primeira pessoa: andar, olhar, interagir, segurar a vela e ler.

@export var walk_speed := 2.6
@export var sprint_speed := 4.6
@export var mouse_sensitivity := 0.0022
@export var gravity := 9.8

var has_candle := false
var reading := false

@onready var _head: Node3D = $Head
@onready var _ray: RayCast3D = $Head/Camera/InteractRay
@onready var _hand_light: LightSource = $Head/Camera/HandLight
@onready var _prompt: Label = $Hud/Prompt
@onready var _reader: PanelContainer = $Hud/Reader
@onready var _reader_text: Label = $Hud/Reader/Text


func _ready() -> void:
	_ray.add_exception(self)
	_hand_light.visible = false
	_reader.visible = false
	_prompt.text = ""
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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
	elif event.is_action_pressed("ui_cancel"):
		if reading:
			close_text()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	var input := Vector2.ZERO
	if not reading:
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var wish := MoveMath.wish_velocity(input, global_basis, speed)
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
	var target := current_target()
	if target != null:
		target.interact(self)


func equip_candle() -> void:
	has_candle = true
	_hand_light.visible = true
	_hand_light.light()


func show_text(text: String) -> void:
	reading = true
	_reader_text.text = text
	_reader.visible = true


func close_text() -> void:
	reading = false
	_reader.visible = false
