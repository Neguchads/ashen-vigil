class_name EnemyDef
extends ContentDef
## Atributos e modelo de criatura editáveis pelo registro e por mods.

@export var display_name := "Lobo"
@export var max_health := 48.0
@export var damage := 18.0
@export var speed := 2.7
@export var aggro_range := 7.0
@export var leash_range := 14.0
@export var attack_range := 1.35
@export var attack_duration := 1.2
@export var strike_delay := 0.55
@export var scene: PackedScene
@export var model_scale := Vector3.ONE
@export var model_rotation := Vector3.ZERO
@export var idle_animation := ""
@export var move_animation := ""
@export var attack_animation := ""
@export var hit_animation := ""
@export var death_animation := ""


func get_content_type() -> StringName:
	return &"enemy"
