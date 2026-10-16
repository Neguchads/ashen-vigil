# Biblioteca de assets

Download solicitado em 2026-10-16: **cinco pacotes CC0, 53,4 MiB transferidos**.
Nada foi comprado; não há serviço ou biblioteca de código nova.

| Pasta em `asset_library/` | Conteúdo | Transferido |
|---|---|---|
| `quaternius_animals` | Cinco animais animados: lobo, cachorro, gato, águia e piranha; FBX, OBJ e Blender | 1,97 MiB |
| `kaykit_adventurers` | Cinco variantes de personagens, incluindo cavaleiro de armadura; armas, escudos e animações | 18,00 MiB |
| `kaykit_skeletons` | Quatro esqueletos de RPG com animações e equipamentos | 18,76 MiB |
| `kaykit_medieval` | 221 modelos glTF: construções, terrenos e decoração, com variantes de cor | 12,15 MiB |
| `quaternius_rpg` | Treze objetos de RPG, incluindo capacetes, escudos e armas; formatos alternativos e imagens | 2,50 MiB |

As licenças e links originais estão em `CREDITS.md`. `asset_library/manifest.json`
registra a URL, o tamanho e o SHA256 de cada download. Para os pacotes compactados,
o hash é do ZIP original; os conteúdos extraídos estão na biblioteca.

## Integrado ao jogo

- `game/assets/quaternius/wolf.fbx`: modelo do lobo, descanso e caminhada.
- `game/assets/kaykit/knight.glb`: viajante de armadura, com animação de descanso.
- `game/assets/medieval/`: construção e poço, com suas dependências.
- `game/assets/manifest.json`: arquivos usados em execução, hashes e origem na biblioteca.

A seleção de execução ocupa cerca de **4,13 MiB**, antes dos caches do Godot.
Os demais arquivos ficam disponíveis na biblioteca e não são carregados pelo jogo.
Os arquivos Blender da biblioteca não são importados ou executados automaticamente.

## Trocar um modelo

O lobo usa `EnemyDef` em `game/core/enemies/wolf.tres`: `scene`, `model_scale`,
`model_rotation` e os nomes de animação. A escala foi conferida usando a pose
deformada do modelo. O FBX original possui descanso/caminhada; o avanço de ataque
e a queda são animações de transformação do jogo, não clipes adicionais do pacote.

O viajante e as construções ficam em `game/src/world/camp.tscn`.
Os modelos KayKit incluem outros clipes, mas somente o descanso do viajante está
ligado à lógica atual. A biblioteca de esqueletos foi baixada e catalogada; os
esqueletos ainda não foram colocados na cena.

O Ultimate Animated Animal Pack mais recente foi consultado no site do autor,
mas o download público no Google Drive respondeu com cota esgotada. Foi usado
o pacote que o próprio Quaternius publicou no OpenGameArt.

## Limites

Os pacotes são estilizados, não definem a arte final de fantasia sombria.
A biblioteca inclui partes de armadura e personagens já vestidos; ainda não
existe sistema de equipar armaduras no jogador. Construções são cenográficas,
com colisões simples. Não há cidade navegável ou interiores novos.
