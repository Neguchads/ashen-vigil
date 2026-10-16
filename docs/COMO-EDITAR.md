# Como editar

Este mapa cresce a cada plano. Quase tudo se edita no painel do Godot (Inspector), sem programar.

| Quero mudar | Onde |
|---|---|
| Texto da carta | `game/src/world/room.tscn`, nó `Letter`, propriedade `text` |
| Posição da cama, mesa, porta e janela | `game/src/world/room.tscn`, nós dentro de `Shell` (formas CSG) |
| Feixe de luar da janela (força, cor, alvo) | `game/src/world/room.tscn`, nó `MoonBeam`; o ponto iluminado é a propriedade `target` |
| Quantidade e tamanho da floresta, clareira, semente | `game/src/world/forest.tscn`, propriedades do nó `Forest` |
| Modelo de árvore e material do chão | `game/src/world/forest.tscn`, propriedades `tree_scene` e `ground_material` (vazio = greybox) |
| Névoa, céu e luz ambiente | `game/src/world/night_environment.tres` |
| Cor e força da lua | `game/src/main/main.tscn`, nó `Moon` |
| Onde o jogador acorda | `game/src/main/main.tscn`, nó `Player`, posição e rotação |
| Velocidade de andar e correr, sensibilidade do mouse | `game/src/player/player.tscn`, propriedades do nó `Player` |
| Duração, brilho e alcance da vela | `game/src/player/player.tscn`, nó `Head/Camera/HandLight` |
| Teclas | `game/src/core/input_actions.gd` |
