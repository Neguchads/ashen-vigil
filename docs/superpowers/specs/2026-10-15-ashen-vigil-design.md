# Ashen Vigil — especificação de design (Capítulo 1: O Despertar)

- Data: 2026-10-15 (revisão 4: escolhas, efeito borboleta, identidade por capítulo e fragmentos de memória)
- Status: aguardando revisão do Gustavo
- Nome: `ashen-vigil` é provisório
- História do capítulo: `docs/historia/capitulo-1.md`
- Bíblia do mundo: `docs/historia/mundo.md`

## 1. Objetivo

RPG de fantasia em 3D, jogado em primeira pessoa com opção de terceira. Combina a sensação de Gothic, Skyrim, Dark Souls/Elden Ring, Fable e Castlevania com o tom de Tolkien e Harry Potter. Usa um loop de "retorno pela morte" inspirado em Re:Zero, e escolhas com consequências e efeito borboleta inspiradas em Witcher 3, Fallout 4 e Life is Strange. Cada capítulo tem uma identidade própria: o primeiro mistura terror, suspense e drama; os seguintes abrem para aventura nostálgica, gótico e épico. Precisa ser leve, imersivo, cinematográfico e nostálgico, ter coop online com amigos e ser fácil de editar e de modificar com mods.

Uso: portfólio gratuito. Público: o Gustavo e os amigos dele.

**Critério de sucesso da fatia vertical (Capítulo 1).**

- Um grupo de 1 a 4 jogadores acorda, explora floresta e caverna e encontra a espada da runa.
- O grupo morre e volta pelo menos uma vez.
- O grupo usa uma pista descoberta num loop anterior para passar pelos guardas da muralha.
- Pelo menos uma escolha feita na floresta muda algo visível na cena da muralha.
- O Gustavo aprova o visual e o som como "digno de cinema".
- O jogo roda a pelo menos 60 fps em 1080p numa RTX 3060.
- Uma arma nova entra no jogo só pela pasta de mods, sem tocar no código.

### O que foi dito e o que foi suposto

| Dito pelo Gustavo | Suposto (pode corrigir) |
|---|---|
| Godot no PC, 1ª e 3ª pessoa | Combate de estilo souls-like |
| Coop com 2 a 4 amigos | Assets gratuitos, sem arte feita do zero |
| Gratuito, portfólio, sem login | Mundo e nomes próprios; Tolkien, HP, Castlevania e Re:Zero só como inspiração |
| Modelos com detalhe de PS3; floresta e castelo | Jogadores confiáveis entre si (sem antitrapaça) |
| Tudo editável; mods estilo Skyrim | O prazo do loop aparece no mundo (lua, sinos), não num cronômetro |
| No futuro, modo criativo estilo Roblox e Garry's Mod | O lobisomem é a ameaça que pune o atraso (proposta, seção 3.3) |
| Acorda na cama, sem memória, sem classe, sem arma, sem tutorial | |
| Vela, carta "estamos te observando" | |
| Adaga, lobo, caverna com arqueiro morto e arco, sinais de lobisomem | |
| Espada enferrujada com runa que pisca e desperta magia escondida | |
| Risadas de criança, música ambiente, clima de cinema | |
| Retorno pela morte estilo Re:Zero, com prazo para cada parte | |
| Guardas bloqueiam a muralha; é preciso convencê-los | |
| Em coop, o grupo volta junto | |
| Ao voltar, mantém só o diário de pistas | |
| Escolhas mudam o final e o mundo (Witcher 3, Fallout 4) | Escolhas viram definitivas ao concluir uma parte principal (seção 3.5) |
| Efeito borboleta (Life is Strange) | Em coop, quem interage decide a escolha |
| Ambientação de RPG: Tolkien, HP, Souls, Elden Ring, Fable, Castlevania | Os tons dos capítulos 2 em diante são proposta (`mundo.md`) |
| Cada cenário com o clima que combina com ele; cada capítulo com essência própria | |
| Começo com terror, drama e suspense; depois nostalgia e aventura | |

## 2. Escopo

### Entra no Capítulo 1

- **Mapa:** quarto onde o jogador acorda → floresta → caverna pequena → clareira da espada da runa → estrada → muralha do castelo. As áreas são ligadas sem tela de carregamento.
- **Câmera:** 1ª e 3ª pessoa, alternadas por tecla. A abertura é sempre em 1ª pessoa.
- **Combate:** stamina, ataque leve, ataque pesado, esquiva com invulnerabilidade, bloqueio e atordoamento.
- **Armas:** adaga, arco e espada da runa. O jogador não tem classe; a forma de jogar nasce do que ele acha.
- **Magia:** uma magia, a da runa, que desperta durante a história.
- **Inimigos:** lobo (e matilha) e lobisomem (ameaça, seção 3.3). Os guardas são personagens de diálogo; se atacados, matam o jogador.
- **Retorno pela morte**, relógio do mundo, âncora e diário de pistas (seção 3).
- **Escolhas com consequência**, provisórias no loop e definitivas ao concluir uma parte (seção 3.5).
- **Diálogo com condições:** as falas dependem das pistas do diário.
- **Luz:** vela e tocha como fontes de luz que o jogador carrega.
- **Inventário mínimo:** equipar arma, segurar a vela ou a tocha, usar cura.
- **Cenas cinematográficas** curtas e música adaptativa (seção 4).
- **Coop** para 1 a 4 jogadores.
- **Mods de dados e de assets**, mais 1 mod de exemplo.
- **Console de desenvolvedor.**
- **Menus:** principal, hospedar, entrar, opções, mods ativos e diário.

### Fica de fora (capítulo 2 ou depois)

- Castelo por dentro, masmorra e chefe.
- Mundo aberto grande, criação de personagem, crafting, níveis e atributos de RPG.
- Começos alternativos (guardados em `docs/historia/ideias.md`).
- Modo criativo e mods com script (seção 11).
- Servidor dedicado, relay de conexão, Steam Workshop e mod.io.

## 3. Loop temporal e escolhas

### 3.1 Regras

- **Âncora:** o ponto para onde o jogador volta. No começo é a cama. A âncora só avança quando o grupo conclui uma **parte principal**. No Capítulo 1, as partes são: sair da floresta com a espada da runa, e passar pela muralha.
- **Gatilhos de retorno:**
  - O grupo inteiro morre.
  - O prazo da parte atual acaba (o relógio do mundo chega à hora-limite).
  - Um evento fatal da história acontece (o guarda mata quem tenta forçar a passagem).
- **No retorno, o mundo reseta:** inimigos, itens, portas e personagens voltam ao estado da âncora, e o inventário volta ao que se tinha na âncora.
- **O que persiste:** o diário (pistas e fragmentos de memória), o número do loop, as partes principais concluídas e as escolhas já definitivas.
- **Transição:** efeito de "memória voltando" (som, distorção de imagem, fragmentos da morte) e a pessoa acorda de novo na âncora.

### 3.2 Coop no loop

- Quem morre vira um **espectro**: assiste aos outros e não interage.
- O loop reinicia para todos quando o último vivo morre, ou quando o prazo acaba.
- As pistas são do grupo. Pista descoberta por um entra no diário de todos (o host decide e sincroniza).
- O host guarda o estado do loop. Ao entrar no meio de uma partida, o cliente nasce na âncora atual com o diário do grupo.

### 3.3 Relógio do mundo e prazo

- **Relógio:** a noite avança em tempo de jogo. Proposta: 1 hora do jogo equivale a 2 minutos reais, com o valor editável em `.tres`.
- **O prazo aparece no mundo, não na tela:** a lua se move, o céu muda de cor e sinos tocam ao longe a cada hora.
- **Proposta de punição pelo atraso:** depois de certa hora, o lobisomem começa a caçar o grupo na floresta. Isso liga os sinais da caverna à ameaça real e dá tensão sem cronômetro. Os números (hora-limite e duração) ficam no `.tres` da parte.

### 3.4 Pistas e diário

- **Uma pista é um `ClueDef`** (com ID, texto do diário e um ícone opcional), registrada no `ContentRegistry` como todo o resto.
- **Como se descobre uma pista:** lendo uma carta, examinando um corpo ou ouvindo uma conversa. Ao descobrir, o diário registra automaticamente, com o efeito de "memória".
- **Pistas destravam caminhos:** opções de diálogo, interações ou rotas novas. Exemplo: no corpo do arqueiro está a senha da guarda; no próximo loop, a senha convence o guarda.

### 3.5 Escolhas e efeito borboleta

- **Uma escolha é um registro no estado do mundo,** por exemplo `core:spared_wounded_wolf = true`. Cada escolha é um `ChoiceDef` (ID, valores possíveis, texto do aviso no diário).
- **Dentro de um loop, a escolha é provisória.** Ela tem efeito imediato, mas o loop a desfaz.
- **Ao concluir uma parte principal, as escolhas daquele loop viram definitivas.** A linha do tempo que o jogador fecha é a que vale. Voltar no tempo serve para sobreviver e também para mudar o resultado.
- **Consequência atrasada (efeito borboleta):** a escolha pode aparecer muito depois, no fim do capítulo, no capítulo seguinte ou no final. Um aviso discreto no diário mostra que algo foi registrado.
- **Controle do custo de conteúdo,** com as técnicas de Witcher 3 e Fallout 4:
  - Galhos que se reencontram: a história se divide e volta a um ponto comum.
  - Muitas consequências pequenas: um personagem lembra, uma carta muda, uma porta fica aberta.
  - Final calculado a partir de poucas escolhas-chave. Cada final é um `EndingDef` com condições.
- **Quem lê as escolhas:** diálogos (condições do Dialogue Manager), `Spawner` (o que aparece), `Interactable` (o que está disponível) e o cálculo de final.
- **Coop:** quem interage decide, como em Baldur's Gate 3. O host registra e todos veem o resultado. Votação fica para depois, se fizer falta.
- **No Capítulo 1:** o sistema completo e duas ou três escolhas com consequência visível ainda no capítulo (exemplos em `capitulo-1.md`). Finais múltiplos dependem de mais capítulos; aqui só se plantam as sementes.

### 3.6 Fragmentos de memória e flashbacks

- **História:** o protagonista sente cheiros, vê visões e ouve sons de realidades paralelas que viveu, e nunca lembra tudo (`mundo.md`).
- **Um fragmento é um `FragmentDef`:** ID, texto curto no diário e a sequência sensorial. O diário tem duas seções: pistas e fragmentos. Fragmentos também sobrevivem ao loop.
- **`FlashbackTrigger`:** área ou interação que dispara uma sequência curta (2 a 6 segundos), com shader de distorção, som posicionado, uma descrição de cheiro ou sensação na tela e, opcionalmente, figuras fantasmas. O jogador não perde o controle por completo.
- **Fragmentos destravam** escolhas e falas, igual às pistas (`Journal.has_fragment(id)`).
- **Em coop:** cada jogador vê o próprio flashback, mas o fragmento entra no diário do grupo.

## 4. Imersão e cinema

- **Identidade por capítulo e por cenário.** Cada capítulo tem um tom próprio, e cada cenário usa o clima que combina com ele, sem forçar o gótico em tudo. O Capítulo 1 é terror, suspense e drama. Os seguintes abrem para aventura nostálgica (vilas estilo Fable, paisagens estilo Tolkien), o gótico de Castlevania, o mistério mágico de Harry Potter e as ruínas épicas de Souls e Elden Ring. A bíblia do mundo, em `docs/historia/mundo.md`, guarda o tom de cada um.
- **Tecnicamente, cada capítulo é um `ChapterDef`** com preset visual, conjunto de músicas e sons de ambiente. Mudar o clima de um cenário é editar dados, não código.
- **Direção de arte:** modelos e texturas com detalhe da era PS3 e iluminação moderna do Godot 4 (renderizador Forward+):
  - névoa volumétrica, iluminação global (SDFGI), oclusão de ambiente e sombras suaves;
  - a lua como luz principal; vela e tocha como luz que o jogador carrega.
- **Preset visual por área** (`WorldEnvironment`): paleta, névoa e luz próprias. Misturar assets de estilos diferentes é a maior causa de visual amador, e o preset corrige isso.
- **Música adaptativa** com `AudioStreamInteractive`, recurso nativo do Godot:
  - camadas por estado (exploração, tensão, combate, revelação);
  - transições no compasso certo;
  - silêncio usado de propósito.
- **Som 3D:** reverberação por ambiente (caverna, floresta aberta), passos por tipo de chão, risadas de criança como evento sonoro posicionado no espaço.
- **Cenas curtas sem tirar o controle quando possível:** câmera guiada por `AnimationPlayer` para o despertar, a carta, a runa piscando e a primeira aparição do lobisomem.
- **Sem tutorial:** o ambiente ensina. A primeira adaga aparece antes do primeiro lobo, e a primeira vela antes da primeira escuridão total.
- **Fontes de asset** (licença conferida asset a asset e registrada em `CREDITS.md`):
  - Poly Haven (CC0): texturas, árvores, rochas e céus.
  - Mixamo: humanos e animações. Gratuito com conta Adobe; o uso dentro do jogo é permitido, mas o arquivo cru não pode ser redistribuído.
  - Fab, Sketchfab e OpenGameArt: kits modulares, criaturas (lobo, lobisomem) e objetos. Só entra asset CC0, CC-BY ou com licença que permita uso em qualquer motor (como a licença padrão do Fab).
  - Sonniss GDC: sons sem royalties.
  - Música: CC0 ou CC-BY de qualidade cinematográfica. É o asset gratuito mais difícil de achar (seção 14).

## 5. Arquitetura

### 5.1 Estrutura de pastas

```
ashen-vigil/
  game/                      projeto Godot
    project.godot
    core/                    "mod zero": todo o conteúdo do jogo base
      mod.json
      items/ weapons/ spells/ enemies/ clues/ dialogue/ areas/ props/ music/
    src/
      autoload/              mod_loader.gd, content_registry.gd, net.gd, loop_manager.gd,
                             world_clock.gd, journal.gd, choices.gd, save_game.gd,
                             settings.gd, dev_console.gd
      content/               classes de definição (ItemDef, WeaponDef, ClueDef...)
      components/            health.gd, stamina.gd, hitbox.gd, hurtbox.gd, spawner.gd,
                             interactable.gd, light_source.gd, resettable.gd,
                             flashback_trigger.gd
      player/                player.tscn, camera_rig.gd, combat_controller.gd, states/, spectator.gd
      enemies/               enemy.tscn, enemy_ai.gd, werewolf_hunt.gd
      world/                 area_root.gd, anchor.gd, cutscene.gd
      ui/                    hud, menus, journal_view
    tests/                   testes GdUnit4
    addons/                  terrain_3d, gdUnit4, dialogue_manager
  mods/example_weapon/       código-fonte do mod de exemplo
  scripts/                   check.ps1, build_mod.ps1, benchmark.ps1
  docs/                      COMO-EDITAR.md, MODDING.md, COOP.md, DECISIONS.md,
                             historia/, superpowers/
  CREDITS.md  README.md  ROADMAP.md
```

### 5.2 Autoloads (scripts globais, um de cada)

| Autoload | Responsabilidade |
|---|---|
| `ModLoader` | Lê os mods na ordem de carga, monta os `.pck` e entrega as definições ao registro |
| `ContentRegistry` | Mapa de ID para definição. `get_def(id)`, `register(def)`, `list(type)` |
| `Net` | Hospedar, entrar, aperto de mão (versão e mods), lista de jogadores |
| `LoopManager` | Âncora atual, número do loop, gatilhos de retorno e reset do mundo |
| `WorldClock` | Hora do jogo, sinais `hour_changed` e `deadline_reached`; move a lua e o céu |
| `Journal` | Pistas e fragmentos de memória, `has_clue(id)`, `has_fragment(id)`, `discover(id)`; sincronizado pelo host |
| `Choices` | Escolhas provisórias do loop e definitivas. `choose(id, valor)`, `get_choice(id)`, `commit()` ao concluir uma parte; sincronizado pelo host |
| `SaveGame` | Lê e grava o save do loop e o de configurações (JSON versionado) |
| `Settings` | Teclas, gráficos e áudio. Arquivo `user://settings.cfg` |
| `DevConsole` | Comandos de teste e de criação (seção 9) |

### 5.3 Componentes

Cada componente faz uma só coisa e é reaproveitado.

- **`Health` e `Stamina`:** vida, dano, morte, gasto e recuperação.
- **`Hitbox` e `Hurtbox`:** áreas de acerto ligadas a uma `WeaponDef`. O arco cria um projétil com `Hitbox`.
- **`CombatController`:** máquina de estados `Idle`, `LightAttack`, `HeavyAttack`, `Aim` (arco), `Cast` (magia), `Dodge`, `Block`, `Stagger` e `Dead`. Cada estado é um script, e a transição só acontece se o estado atual permitir.
- **`CameraRig`:** alterna entre 1ª pessoa (braços, arma e vela visíveis) e 3ª pessoa (câmera de ombro com colisão).
- **`Spectator`:** modo espectro do jogador morto em coop.
- **`EnemyAI`:** estados `Patrol`, `Chase`, `Attack` e `Return`, com `NavigationAgent3D`. `WerewolfHunt` liga a caçada ao `WorldClock`.
- **`Interactable`:** examinar, pegar, ler ou acender. Pode chamar `Journal.discover(id)`.
- **`LightSource`:** vela e tocha, com duração e chance de apagar com vento ou água (valores no `.tres`).
- **`Resettable`:** todo objeto que muda durante o loop (porta, item no chão, inimigo) guarda o estado inicial e volta a ele quando o `LoopManager` emite `loop_reset`.
- **`Spawner`:** nó colocado no editor com um `content_id`; cria o conteúdo daquele ID e se registra como `Resettable`.

## 6. Conteúdo orientado a dados (editável)

- **Toda definição é um `Resource` (`.tres`) com campo `id`** no formato `<mod>:<nome>`, por exemplo `core:rusty_dagger`. Classes: `ItemDef`, `WeaponDef`, `SpellDef`, `EnemyDef`, `ClueDef`, `FragmentDef`, `ChoiceDef`, `EndingDef`, `PartDef` (parte principal: âncora, prazo, condição de conclusão), `ChapterDef` (tom, preset, músicas), `AreaDef` e `PropDef`.
- **Números ficam fora do código:** dano, vida, stamina, alcance, prazo, duração da vela e velocidade do relógio.
- **O código só procura conteúdo pelo ID**, nunca por caminho de arquivo.
- **Diálogos são arquivos `.dialogue`** do Dialogue Manager, escritos como texto. As condições usam o diário e as escolhas: `if Journal.has_clue("core:guard_password")` ou `if Choices.get_choice("core:spared_wounded_wolf")`. Editar uma fala não exige programar.
- **Cada área é uma cena separada,** com um preset visual próprio e `Spawner` para o conteúdo dinâmico.
- **`docs/COMO-EDITAR.md`** é o mapa "quero mudar X → arquivo Y".

## 7. Mods

### 7.1 Modelo "mod zero"

O jogo base é o mod `core`, carregado pelo mesmo caminho que qualquer mod. Se o `core` funciona, o sistema de mods funciona.

### 7.2 Formato de um mod

```
user://mods/<mod_id>/
  mod.json
  <mod_id>.pck        cenas, modelos, texturas, sons, .tres e .dialogue
```

```json
{
  "id": "example_weapon",
  "name": "Espada de Exemplo",
  "version": "1.0.0",
  "game_version": ">=0.1.0",
  "load_after": ["core"],
  "content": ["res://mods/example_weapon/rusty_blade.tres"]
}
```

### 7.3 Carregamento

1. O `ModLoader` lê `core` e depois cada pasta de `user://mods/`, que fica em `%APPDATA%\Godot\app_userdata\Ashen Vigil\mods`.
2. Ordena os mods por `load_after`. Se houver ciclo ou dependência ausente, o mod é desativado e o motivo aparece no menu.
3. Monta cada `.pck` com `ProjectSettings.load_resource_pack()`. Um arquivo com o mesmo caminho de um existente o substitui, como os replacers do Skyrim.
4. Registra cada definição de `content`. Um ID repetido substitui o anterior, e a ordem de carga decide quem vence.
5. Se um mod for inválido, ele é ignorado com aviso. O jogo não fecha.

`scripts/build_mod.ps1` empacota uma pasta de mod em `.pck` usando o Godot por linha de comando.

### 7.4 Níveis de mod

1. **Dados:** números, armas, inimigos, pistas, escolhas, finais e diálogos. Entra no MVP.
2. **Assets e cenas:** modelos, sons e áreas novas. Entra no MVP.
3. **Scripts:** fora do MVP. Candidato: Godot Mod Loader (CC0). Em 2026-10 o suporte a Godot 4 está numa branch em desenvolvimento, sem versão lançada. Reavaliar no capítulo 2.

### 7.5 Segurança

Um `.pck` pode conter scripts, e o Godot não isola esses scripts. Por isso:

- O `docs/MODDING.md` avisa que mod roda código no PC de quem instala.
- O menu mostra os mods ativos.
- O `ModLoader` registra só definições listadas em `content`. Isso reduz o risco, mas não elimina, porque um `.tres` pode apontar para um script embutido no `.pck`.

## 8. Coop online

### 8.1 Modelo

- **Rede de alto nível do Godot:** `ENetMultiplayerPeer`, `MultiplayerSpawner`, `MultiplayerSynchronizer` e RPC.
- **Partida:** 1 a 4 jogadores. Porta padrão 24565, configurável. Jogar sozinho é hospedar sem clientes, então existe um só caminho de código.
- **Divisão de autoridade:**
  - Cada jogador decide o próprio movimento, animação, stamina e vida.
  - O host decide inimigos, itens, portas, relógio, diário, escolhas, âncora e loop.
  - **Por quê:** autoridade total do host exigiria prever e corrigir o movimento de cada cliente, uma complexidade de jogo competitivo desnecessária entre amigos.

### 8.2 Fluxos

- **Entrar:**
  1. O cliente envia `{game_version, mods: [{id, version}]}`.
  2. O host compara com a própria lista. Se for diferente, recusa com o motivo.
  3. Se for igual, o cliente nasce na âncora atual e recebe o diário, a hora e o número do loop.
- **Jogador acerta inimigo:**
  1. O cliente chama o RPC `request_hit(enemy_id, weapon_id, attack_kind)`.
  2. O host valida: o inimigo existe e está vivo, a distância é no máximo o alcance mais uma tolerância, e o intervalo mínimo entre acertos foi respeitado.
  3. O host aplica o dano e sincroniza a vida.
- **Inimigo acerta jogador:** o host envia `take_hit(damage, stagger)` ao dono do jogador.
- **Pista descoberta:** o cliente pede `request_discover(clue_id)`; o host registra e envia a todos.
- **Escolha feita:** o cliente que interagiu pede `request_choice(choice_id, valor)`; o host registra e envia a todos.
- **Morte:** o jogador vira espectro. Quando o último vivo morre, o host emite `loop_reset` para todos.
- **Desconexão do host:** os clientes voltam ao menu com uma mensagem. Migração de host fica fora do MVP.

### 8.3 Conexão

IP e porta, com o guia `docs/COOP.md` para jogar via Tailscale ou Radmin VPN, sem abrir porta no roteador. Relay fica para depois.

## 9. Save e console

### 9.1 Save

- **`user://saves/loop.json`** (do host):
  - partes concluídas, âncora atual e número do loop;
  - pistas do diário;
  - escolhas definitivas (as provisórias não são salvas, porque o loop as desfaz);
  - lista de mods.
- **Sair no meio do loop:** ao voltar, o jogo recomeça na âncora. Isso é coerente com a história e dispensa salvar o mundo inteiro.
- **Formato:** `schema_version` no arquivo. A gravação é atômica (escreve num arquivo temporário e depois renomeia), para um travamento não corromper o save.

### 9.2 Console de desenvolvedor

A tecla F1 abre o console. Comandos do MVP:

- `help`, `list <tipo>`, `mods`;
- `spawn <id> [qtd]`, `give <id> [qtd]`, `god`;
- `clue <id>` (adiciona uma pista), `choice <id> <valor>`, `time <hh:mm>`, `loop` (força o retorno), `anchor <parte>`.

Em coop, comandos que mudam o mundo só funcionam no host.

## 10. Testes e verificação

- **`scripts/check.ps1`,** um comando, roda:
  1. `gdformat --check` e `gdlint` (gdtoolkit 4.x).
  2. Os testes unitários GdUnit4 em modo headless.
  3. O teste de rede: duas instâncias headless conectam, o cliente envia `request_hit` e `request_discover`, e as duas confirmam a mesma vida do inimigo e o mesmo diário.
  4. O teste de loop em rede: os dois jogadores morrem, as duas instâncias recebem `loop_reset`, o mundo volta ao estado da âncora, o diário continua e as escolhas provisórias somem.
  5. O teste de mods: carrega `example_weapon` e confirma que `example_weapon:rusty_blade` existe e pode ser criado.
- **Testes unitários obrigatórios:**
  - `Health`, `Stamina` e transições do `CombatController`.
  - `LoopManager`: cada gatilho de retorno, o reset de `Resettable` e o que persiste.
  - `WorldClock`: hora avançando e `deadline_reached` no momento certo.
  - `Journal`: descobrir, repetir sem duplicar e ler a condição usada no diálogo.
  - `Choices`: escolha provisória desfeita no loop, `commit()` ao concluir a parte e cálculo de `EndingDef`.
  - Validação de `request_hit`, ordenação de mods, conflito de ID e comparação de mods no aperto de mão.
  - Save: ler e gravar, `schema_version` e arquivo corrompido.
- **Desempenho:** `scripts/benchmark.ps1` percorre a câmera em trajeto fixo por cada área e grava o fps médio e o mínimo. Critério: média de pelo menos 60 fps e mínimo de pelo menos 45 em 1080p na RTX 3060. Na GTX 1060 não há como testar; fica como estimativa.
- **Visual e som:** capturas de tela e vídeo do jogo rodando, com aprovação do Gustavo. Teste automático não julga clima.
- **Segredos:** o projeto não usa chaves nem `.env`. Mesmo assim, o `.gitignore` inclui `.env` e a varredura de segredos roda antes de cada PR.

## 11. Futuro (não entra no MVP; a arquitetura já prepara)

- **Capítulo 2:** castelo, masmorra e chefe, com novas partes principais e âncoras.
- **Modo criativo estilo Garry's Mod:**
  - menu para gerar qualquer definição registrada;
  - ferramenta para mover, girar e escalar;
  - objetos com física e construção em coop;
  - a construção salva como lista de `{id, transform}` e exportada como mod.
- **Scripts dentro do jogo estilo Roblox:** linguagem isolada (provavelmente Lua com sandbox). É a parte mais cara e mais arriscada.
- **Outros:** começos alternativos, relay de conexão, Steam Workshop ou mod.io, mods com script.

## 12. Ferramentas (conferidas em 2026-10-15)

| Ferramenta | Versão | Licença | Observação |
|---|---|---|---|
| Godot | 4.7.2 estável (18/08/2026) | MIT | Versão fixada no projeto |
| Terrain3D | 1.0.x | MIT | Builds declaradas até 4.6+; compatibilidade com 4.7 confirmada no teste visual |
| Dialogue Manager | versão atual (Godot 4.6+) | MIT | Diálogos em texto, com condições |
| GdUnit4 | 6.2.x | MIT (confirmar o LICENSE ao instalar) | A linha 6.x exige Godot 4.5 ou mais novo |
| gdtoolkit | 4.x (pip) | MIT | Precisa de Python |
| Godot Mod Loader | branch 4.x-dev | CC0 | Só no capítulo 2 |
| Git LFS (GitHub Free) | — | — | Grátis até 10 GiB de armazenamento e 10 GiB de download por mês |

**Assets grandes.** Versionar assets importados e otimizados via Git LFS, sem os originais crus (listados em `CREDITS.md` com link). Se o projeto passar de 8 GiB, reavaliar antes de estourar a cota.

## 13. Riscos

| Risco | Mitigação |
|---|---|
| Escopo crescer (o risco nº 1 de jogo solo) | Capítulo 1 fechado; nada do capítulo 2 antes de ele ficar jogável |
| Faltar lobisomem animado gratuito | Buscar cedo, no teste visual. Plano B: aparição só em silhueta e som, nunca de corpo inteiro, o que também assusta mais |
| Música cinematográfica gratuita fraca | Buscar CC0 e CC-BY cedo; plano B: poucas faixas fortes com muito silêncio e som ambiente |
| Galhos da história explodirem em conteúdo | Galhos que se reencontram, consequências pequenas e final calculado por poucas escolhas-chave |
| Loop frustrar (repetir trechos longos) | Prazos curtos, âncoras próximas e caminhos mais rápidos para quem já conhece |
| Reset do mundo deixar algo para trás | Todo objeto mutável é `Resettable`, com teste automático de reset |
| Terrain3D incompatível com Godot 4.7 | Confirmar no teste visual; plano B: terreno esculpido como malha |
| Conexão entre amigos (roteador) | VPN gratuita no MVP; relay depois |
| Desempenho com floresta densa e névoa | MultiMesh, níveis de detalhe (LOD) e benchmark por área |

## 14. Ordem de entrega (vira o plano)

> Atualizado em 2026-10-16: a ordem real, com algo jogável no fim de cada etapa, está em `docs/superpowers/plans/2026-10-15-00-indice.md`. A lista abaixo é a ordem original.

0. **Teste visual e sonoro descartável:** clareira de floresta à noite, com névoa, lua, vela e música. Mede o fps e procura lobo e lobisomem gratuitos. O Gustavo aprova o clima.
1. **Fundação:** projeto Godot, `check.ps1`, lint, GdUnit4, `ContentRegistry`, `ModLoader` com o `core`.
2. **Jogador:** movimento, `CameraRig` em 1ª e 3ª pessoa, `Health`, `Stamina`, `Interactable` e `LightSource`.
3. **Loop:** `LoopManager`, `WorldClock`, `Journal`, `Resettable` e a cena do despertar no quarto.
4. **Combate:** adaga e lobo com IA.
5. **Coop:** `Net`, aperto de mão, sincronização, `request_hit`, espectro e loop em rede.
6. **Diálogo e escolhas:** Dialogue Manager, `Choices`, guardas da muralha e condições por pista e por escolha.
7. **Mods e console:** `.pck`, `mod.json`, mod de exemplo, checagem no coop e `DevConsole`.
8. **Mundo:** floresta, caverna, clareira, estrada e muralha, com o tratamento visual.
9. **História e cinema:** carta, arqueiro morto e arco, espada da runa e magia, risadas, flashbacks, lobisomem, música adaptativa e cenas.
10. **Polimento:** sons, menus, diário, build para Windows e página no itch.io (publicar só com confirmação).
