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
| Velocidade de andar e correr | `game/src/player/player.tscn`, propriedades do nó `Player` |
| Duração, brilho e alcance da vela | `game/src/player/player.tscn`, nó `Head/Camera/HandLight` |
| Teclas | `game/src/core/input_actions.gd` |
| Nome, descrição, dano, alcance e stamina da adaga | `game/core/weapons/rusty_dagger.tres` |
| Modelo da adaga | `game/core/weapons/dagger_model.tscn`; propriedade `scene` no `.tres` da arma |
| Local onde a adaga aparece | `game/src/main/main.tscn`, nó `DaggerSpawn`; `content_id` escolhe a arma |
| Local e distância entre armas de mods | `game/src/main/main.tscn`, nó `ModWeapons`; `mod_weapon_spacing` no nó `Main` |
| Posição da arma na mão | `game/src/player/player.tscn`, nó `Head/Camera/WeaponHand` |
| Lista de conteúdo do jogo base | `game/core/mod.json` |
| Regras de ID | `game/src/content/content_def.gd` |
| Carregamento e ordem dos mods | `game/src/autoload/mod_loader.gd`, `game/src/modding/` |
| Criar uma arma por mod | `mods/example_weapon/`; instruções em `docs/MODDING.md` |
| Dano, vida, velocidade, alcance e modelo do lobo | `game/core/enemies/wolf.tres` |
| Posição do lobo hostil e do ferido | `game/src/main/main.tscn`, nós `HostileWolf` e `WoundedWolf` |
| Texto ao poupar o lobo | `game/src/main/main.tscn`, propriedade `spared_text` de `WoundedWolf` |
| Tempo do golpe e momento do acerto | `.tres` da arma: `attack_duration` e `strike_delay` |
| Custo e duração da esquiva; eficiência do bloqueio | `game/src/player/player.tscn`, nó `Combat` |
| Vida, stamina e recuperação do jogador | `game/src/player/player.tscn`, nó `Vitals` |
| Texto, posição e modelo do viajante | `game/src/world/camp.tscn`, nó `Resident` |
| Construção e poço | `game/src/world/camp.tscn` |
| Corredor sem árvores até o lobo ferido | `game/src/world/forest.tscn`: `trail_half_width`, `trail_length` |
| Preferências de mouse, FOV, gráficos e volume | Esc → configurações; padrões em `game/src/autoload/game_settings.gd` |
| Aparência e textos do menu | `game/src/ui/pause_menu.tscn` |
| Pacotes gratuitos disponíveis | `asset_library/`; catálogo em `docs/ASSETS.md` |
