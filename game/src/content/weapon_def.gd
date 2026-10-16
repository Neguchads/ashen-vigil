class_name WeaponDef
extends ItemDef
## Arma: os números ficam aqui para serem editados sem programar.

@export var damage: float = 10.0
@export var stamina_cost: float = 10.0
## Alcance em metros; o host usa para validar acertos no coop.
@export var reach: float = 1.0
## Cena com o modelo da arma. Opcional até o Plano 04.
@export var scene: PackedScene
@export var attack_duration := 0.55
@export var strike_delay := 0.15


func get_content_type() -> StringName:
	return &"weapon"
