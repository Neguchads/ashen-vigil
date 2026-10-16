class_name Wolf
extends CharacterBody3D
## Lobo hostil e variante ferida. Os dois usam a mesma definição e o mesmo modelo.

@export var content_id: StringName = &"core:wolf"
@export var injured := false
@export_multiline
var spared_text := "Você recua devagar. O lobo continua respirando, sem tentar atacar."

var definition: EnemyDef
var choice := ""
var state := "idle"
var _home := Vector3.ZERO
var _model: Node3D
var _animations: AnimationPlayer
var _attack_remaining := 0.0
var _hit_pending := false
var _pose_motion: Tween

@onready var vitals: CombatVitals = $Vitals
@onready var _interaction: Interactable = $Interaction


func _ready() -> void:
	definition = ContentRegistry.get_def(String(content_id)) as EnemyDef
	if definition == null:
		set_physics_process(false)
		_interaction.enabled = false
		return
	_home = global_position
	vitals.max_health = definition.max_health
	vitals.reset()
	vitals.died.connect(_on_died)
	_interaction.enabled = injured
	_interaction.interacted.connect(_on_interact)
	_interaction.prompt = "acalmar e poupar o lobo ferido"
	if definition.scene != null and definition.scene.can_instantiate():
		var instance := definition.scene.instantiate()
		if instance is Node3D:
			_model = instance as Node3D
			_model.scale = definition.model_scale
			_model.rotation = definition.model_rotation
			$Visual.add_child(_model)
			var players := _model.find_children("*", "AnimationPlayer", true, false)
			if not players.is_empty():
				_animations = players[0] as AnimationPlayer
		elif instance != null:
			instance.free()
	if injured:
		state = "injured"
		vitals.health = minf(18.0, definition.max_health)
		$Visual.rotation.z = PI / 2.0
		$Visual.position.y = 0.3
	_play("idle")


func _physics_process(delta: float) -> void:
	if state in ["dead", "injured", "spared"]:
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.vitals.is_dead():
		return
	var distance := global_position.distance_to(player.global_position)
	if _attack_remaining > 0.0:
		_attack_remaining -= delta
		if (
			_hit_pending
			and _attack_remaining <= definition.attack_duration - definition.strike_delay
		):
			_hit_pending = false
			if distance <= definition.attack_range + 0.2 and _can_see(player):
				player.take_damage(definition.damage, global_position)
		if _attack_remaining <= 0.0:
			state = "idle"
		return
	var destination := _home
	var chasing := distance <= definition.aggro_range or state == "chase"
	chasing = chasing and global_position.distance_to(_home) < definition.leash_range
	if chasing and _can_see(player):
		destination = player.global_position
		if distance <= definition.attack_range:
			state = "attack"
			_attack_remaining = definition.attack_duration
			_hit_pending = true
			_play("attack")
			_animate_lunge()
			return
		state = "chase"
	else:
		state = "return" if global_position.distance_to(_home) > 0.5 else "idle"
	var direction := destination - global_position
	direction.y = 0.0
	velocity.x = 0.0
	velocity.z = 0.0
	if direction.length() > 0.5:
		direction = direction.normalized()
		velocity.x = direction.x * definition.speed
		velocity.z = direction.z * definition.speed
		look_at(global_position + direction, Vector3.UP)
		_play("move")
	else:
		_play("idle")
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()


func take_damage(amount: float, _source: Vector3) -> float:
	var applied := vitals.take_damage(amount)
	if applied > 0.0 and not vitals.is_dead():
		_play("hit")
	return applied


func _on_interact(by: Node) -> void:
	if not by is Player or not injured or vitals.is_dead() or choice != "":
		return
	choice = "spared"
	state = "spared"
	_interaction.enabled = false
	(by as Player).show_text(spared_text)


func _on_died() -> void:
	state = "dead"
	if injured:
		choice = "killed"
	_interaction.enabled = false
	_interaction.collision_layer = 0
	collision_layer = 0
	_play("death")
	if definition.death_animation == "" and _animations != null:
		_animations.pause()
	if _pose_motion != null:
		_pose_motion.kill()
	_pose_motion = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	_pose_motion.tween_property($Visual, "rotation:z", 1.5, 0.4)
	_pose_motion.tween_property($Visual, "position", Vector3(0, 0.3, 0), 0.4)


func _animate_lunge() -> void:
	if _pose_motion != null:
		_pose_motion.kill()
	_pose_motion = create_tween().set_trans(Tween.TRANS_SINE)
	_pose_motion.tween_property($Visual, "position:z", 0.12, definition.strike_delay * 0.7)
	_pose_motion.tween_property($Visual, "position:z", -0.35, definition.strike_delay * 0.3)
	_pose_motion.tween_property(
		$Visual, "position:z", 0.0, definition.attack_duration - definition.strike_delay
	)


func _can_see(player: Player) -> bool:
	var query := PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * 0.65,
		player.global_position + Vector3.UP * 0.9,
		1,
		[get_rid()]
	)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == player


func _play(action: String) -> void:
	if _animations == null:
		return
	var requested: String = definition.get(action + "_animation")
	if requested == "" or not _animations.has_animation(requested):
		return
	if action in ["idle", "move"]:
		_animations.get_animation(requested).loop_mode = Animation.LOOP_LINEAR
	if _animations.current_animation != requested or not _animations.is_playing():
		_animations.play(requested, 0.12)
