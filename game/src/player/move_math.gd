class_name MoveMath
extends RefCounted
## Contas do movimento em primeira pessoa, separadas para serem testadas.

## Limite do olhar para cima e para baixo, em radianos (cerca de 80 graus).
const MAX_PITCH := 1.4


## Converte a direção das teclas (x = lado, y = frente/trás) em velocidade no mundo.
static func wish_velocity(input: Vector2, yaw_basis: Basis, speed: float) -> Vector3:
	var dir := yaw_basis * Vector3(input.x, 0.0, input.y)
	dir.y = 0.0
	if dir.length() > 1.0:
		dir = dir.normalized()
	return dir * speed


static func clamp_pitch(pitch: float) -> float:
	return clampf(pitch, -MAX_PITCH, MAX_PITCH)
