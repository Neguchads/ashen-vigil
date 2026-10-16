# Plano 01: primeiro jogável

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ter as ferramentas e os testes automáticos prontos e uma cena jogável em primeira pessoa: acordar no quarto escuro, pegar a vela, ler a carta e sair para a floresta à noite.

**Architecture:** Tudo começa em *greybox* (formas simples), mas já com a estrutura definitiva: cada parte é uma cena editável no Godot (quarto, vela, carta, floresta, jogador), e os números ficam em `@export`, editáveis no painel. A lógica pura (movimento, luz, espalhar árvores, teclas) fica em funções pequenas e testadas. A arte real entra depois, trocando o modelo nas propriedades, sem reescrever código.

**Tech Stack:** Godot 4.7.2 (GDScript tipado, renderizador Forward+), GdUnit4 v6.2.2, gdtoolkit 4.5.0, PowerShell 7, Git + Git LFS, GitHub CLI.

**Spec:** `docs/superpowers/specs/2026-10-15-ashen-vigil-design.md` (seções 2, 4, 5, 10). Índice: `docs/superpowers/plans/2026-10-15-00-indice.md`.

## Global Constraints

- Godot `4.7.2-stable`. Executável: `$env:GODOT_BIN` se definido; senão `A:\AI\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe`.
- GDScript com tipagem estática em todo código novo. Linhas com no máximo 100 caracteres (padrão do gdtoolkit).
- Identificadores, nomes de arquivo e commits em inglês (Conventional Commits). Comentários e textos de interface em português.
- Versão do jogo em `project.godot`: `application/config/version="0.1.0"`.
- Controles: WASD anda, mouse olha, Shift corre, E interage, Esc fecha a carta ou solta o mouse, clique prende o mouse.
- Alvo de desempenho: média de pelo menos 60 fps e 1% mais baixo de pelo menos 45 fps em 1080p na RTX 3060.
- Todo download pede confirmação ao Gustavo antes (nome, origem e tamanho).
- Nunca commitar na `main`, exceto o commit inicial do repositório. Fluxo: branch → commits → `scripts/check.ps1` verde → revisão `feature-dev:code-reviewer` → PR → merge com `--match-head-commit`.
- Se `gdformat --check` falhar, rodar `.\.venv\Scripts\gdformat.exe game\src game\tests game\tools` e repetir. Se o `gdlint` reclamar da ordem das declarações, reordenar como a mensagem pede. Não desligar regras do lint.
- O hook `guard-organizar` bloqueia `Remove-Item`, `Set-Content`, `Out-File` e similares dentro de `A:\AI\Claude Code Projects`. Criar e editar arquivos usa as ferramentas Write/Edit; apagar arquivos ali exige pedir ao Gustavo.

## Review Focus

1. Olhar totalmente para cima ou para baixo: a câmera trava antes de virar de ponta-cabeça. (Teste na Task 3.)
2. Andar na diagonal não é mais rápido que andar reto. (Teste na Task 3.)
3. O jogador nasce no quarto e fica de pé no chão, sem cair pelo piso. (Teste na Task 4.)
4. Apertar E sem nada na mira, ou pegar a vela de novo depois de já pegá-la, não faz nada e não gera erro. (Testes nas Tasks 3 e 4.)
5. A vela queima até acabar: a luz apaga e não acende de novo; a floresta com clareira impossível (maior que a área) não trava o jogo. (Testes na Task 3.)

---

### Task 1: Ferramentas e repositório

**Files:**
- Create: `.gitignore`, `.gitattributes`, `requirements-dev.txt`
- Já existem (entram no commit inicial): `docs/`, `ROADMAP.md`

**Interfaces:**
- Consumes: nada.
- Produces: Godot em `A:\AI\Tools\Godot\4.7.2\`, ambiente `.venv` com `gdformat` e `gdlint`, repositório Git com LFS e branch `feat/first-playable`.

- [ ] **Step 1: Criar `.gitignore`**

```gitignore
# Godot
.godot/
*.translation
game/reports/
game/GdUnitRunner.cfg

# Builds e saídas
/build/

# Python
.venv/
__pycache__/

# Segredos (o projeto não usa, mas fica protegido)
.env
.env.*
!.env.example
```

- [ ] **Step 2: Criar `.gitattributes` (assets grandes no Git LFS)**

```gitattributes
* text=auto eol=lf
*.ps1 text eol=crlf
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.exr filter=lfs diff=lfs merge=lfs -text
*.hdr filter=lfs diff=lfs merge=lfs -text
*.glb filter=lfs diff=lfs merge=lfs -text
*.fbx filter=lfs diff=lfs merge=lfs -text
*.blend filter=lfs diff=lfs merge=lfs -text
*.wav filter=lfs diff=lfs merge=lfs -text
*.ogg filter=lfs diff=lfs merge=lfs -text
*.mp3 filter=lfs diff=lfs merge=lfs -text
*.pck filter=lfs diff=lfs merge=lfs -text
```

- [ ] **Step 3: Criar `requirements-dev.txt`**

```text
gdtoolkit==4.5.0
```

- [ ] **Step 4: Iniciar o repositório e a branch de trabalho**

```powershell
cd "A:\AI\Claude Code Projects\ashen-vigil"
git init -b main
git lfs install --local
git add .gitignore .gitattributes requirements-dev.txt ROADMAP.md docs
git commit -m "docs: add design spec, project bible and plans

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git switch -c feat/first-playable
```
Expected: `git log --oneline` mostra 1 commit; `git branch --show-current` mostra `feat/first-playable`.

Este é o único commit permitido na `main`: um repositório novo precisa de uma base.

- [ ] **Step 5: Pedir confirmação dos downloads**

Mostrar ao Gustavo e esperar um "sim":
- `Godot_v4.7.2-stable_win64.exe.zip` (86 MB), de `github.com/godotengine/godot/releases/tag/4.7.2-stable` (oficial, MIT).
- GdUnit4 `v6.2.2` (código-fonte da release, de `github.com/godot-gdunit-labs/gdUnit4`, MIT). O tamanho exato aparece ao baixar.
- `gdtoolkit 4.5.0`, do PyPI (MIT).

- [ ] **Step 6: Baixar o Godot e criar o ambiente Python**

```powershell
New-Item -ItemType Directory -Force "A:\AI\Tools\Godot\4.7.2" | Out-Null
gh release download 4.7.2-stable --repo godotengine/godot --pattern "Godot_v4.7.2-stable_win64.exe.zip" --dir "$env:TEMP\godot-dl"
Expand-Archive "$env:TEMP\godot-dl\Godot_v4.7.2-stable_win64.exe.zip" -DestinationPath "A:\AI\Tools\Godot\4.7.2"
& "A:\AI\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe" --version
cd "A:\AI\Claude Code Projects\ashen-vigil"
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\gdformat.exe --version
```
Expected: `4.7.2.stable.official...` e `gdformat 4.5.0`.

---

### Task 2: Projeto Godot, testes e `check.ps1`

**Files:**
- Create: `game/project.godot`, `game/icon.svg`, `game/tests/smoke_test.gd`, `scripts/check.ps1`
- Create (vendorizado): `game/addons/gdUnit4/` (GdUnit4 v6.2.2)

**Interfaces:**
- Consumes: Godot e `.venv` da Task 1.
- Produces: `scripts/check.ps1` (sai com 0 se tudo passar). Todas as tasks seguintes rodam esse comando.

- [ ] **Step 1: Criar `game/project.godot`**

```ini
config_version=5

[application]
config/name="Ashen Vigil"
config/version="0.1.0"
run/main_scene="res://src/main/main.tscn"
config/features=PackedStringArray("4.7", "Forward Plus")
config/icon="res://icon.svg"

[display]
window/size/viewport_width=1920
window/size/viewport_height=1080

[editor_plugins]
enabled=PackedStringArray("res://addons/gdUnit4/plugin.cfg")

[rendering]
renderer/rendering_method="forward_plus"
```

A cena principal só passa a existir na Task 4. Até lá o Godot avisa que ela falta, o que não quebra os testes.

`game/icon.svg`:

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128"><rect width="128" height="128" fill="#14161c"/><circle cx="64" cy="58" r="26" fill="#c9d3e6"/><circle cx="76" cy="50" r="24" fill="#14161c"/></svg>
```

- [ ] **Step 2: Instalar o GdUnit4 v6.2.2**

```powershell
cd "A:\AI\Claude Code Projects\ashen-vigil"
gh release download v6.2.2 --repo godot-gdunit-labs/gdUnit4 --archive zip --dir "$env:TEMP\gdunit-dl"
Expand-Archive "$env:TEMP\gdunit-dl\gdUnit4-6.2.2.zip" -DestinationPath "$env:TEMP\gdunit-dl\x"
New-Item -ItemType Directory -Force game\addons | Out-Null
Copy-Item -Recurse "$env:TEMP\gdunit-dl\x\gdUnit4-6.2.2\addons\gdUnit4" game\addons\gdUnit4
Test-Path game\addons\gdUnit4\bin\GdUnitCmdTool.gd
```
Expected: `True`. Se o nome da pasta extraída for outro, conferir com `Get-ChildItem "$env:TEMP\gdunit-dl\x"`.

- [ ] **Step 3: Escrever o teste de fumaça**

`game/tests/smoke_test.gd`:

```gdscript
extends GdUnitTestSuite
## Garante que o projeto abre e que a versão do jogo está configurada.


func test_game_version_is_set() -> void:
	assert_str(ProjectSettings.get_setting("application/config/version")).is_equal("0.1.0")
```

- [ ] **Step 4: Escrever `scripts/check.ps1`**

```powershell
# Roda formatação, lint, varredura de segredos e testes. Sai com 0 só se tudo passar.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$game = Join-Path $root 'game'
$godot = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { 'A:\AI\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' }
$venv = Join-Path $root '.venv\Scripts'

function Fail([string]$msg, [int]$code = 1) {
    Write-Host "FALHOU: $msg" -ForegroundColor Red
    exit $code
}

if (-not (Test-Path $godot)) { Fail "Godot não encontrado em $godot. Defina GODOT_BIN." }
if (-not (Test-Path (Join-Path $venv 'gdformat.exe'))) { Fail 'gdtoolkit ausente. Rode: py -3.12 -m venv .venv; .\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt' }

$code_dirs = @('src', 'tests', 'tools') | ForEach-Object { Join-Path $game $_ } | Where-Object { Test-Path $_ }

Write-Host '== gdformat --check'
& (Join-Path $venv 'gdformat.exe') --check @code_dirs
if ($LASTEXITCODE -ne 0) { Fail 'formatação. Rode .\.venv\Scripts\gdformat.exe game\src game\tests game\tools' }

Write-Host '== gdlint'
& (Join-Path $venv 'gdlint.exe') @code_dirs
if ($LASTEXITCODE -ne 0) { Fail 'lint' }

Write-Host '== segredos'
Push-Location $root
git grep -nIE '(BEGIN [A-Z ]*PRIVATE KEY|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,})' -- . ':!*.md'
$found = ($LASTEXITCODE -eq 0)
Pop-Location
if ($found) { Fail 'possível segredo no repositório (linhas acima)' }

Write-Host '== importação do projeto'
& $godot --headless --path $game --import
if ($LASTEXITCODE -ne 0) { Fail 'importação do Godot' $LASTEXITCODE }

Write-Host '== testes (GdUnit4)'
& $godot --headless --path $game -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests -c --ignoreHeadlessMode
if ($LASTEXITCODE -ne 0) { Fail "testes (código $LASTEXITCODE; 100 = falhas, 101 = avisos)" $LASTEXITCODE }

Write-Host 'OK: tudo passou' -ForegroundColor Green
```

A varredura de segredos usa `git grep`, então só vê arquivos já adicionados ao git (`git add` antes de rodar).

- [ ] **Step 5: Rodar e ver passar**

Run: `git add -A; pwsh -File scripts/check.ps1`
Expected: termina com `OK: tudo passou`; o GdUnit4 relata 1 teste passando.

Se `--import` não existir nesta versão (erro de argumento), trocar a linha por `& $godot --headless --path $game --editor --quit-after 600` e registrar no `DECISIONS.md`.

- [ ] **Step 6: Ver o teste falhar de propósito (teste de mutação)**

Trocar temporariamente `"0.1.0"` por `"9.9.9"` em `smoke_test.gd`, rodar `pwsh -File scripts/check.ps1` e conferir `FALHOU: testes (código 100 ...)`. Desfazer a troca e rodar de novo até `OK`.

- [ ] **Step 7: Commit**

```powershell
git add game scripts
git commit -m "chore: set up Godot project, GdUnit4 and check script

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Peças do jogador (teclas, movimento, luz e interação)

**Files:**
- Create: `game/src/core/input_actions.gd`, `game/src/player/move_math.gd`, `game/src/components/light_source.gd`, `game/src/components/interactable.gd`, `game/src/world/forest_builder.gd` (só a função `scatter` nesta task; o resto na Task 4)
- Test: `game/tests/core/input_actions_test.gd`, `game/tests/player/move_math_test.gd`, `game/tests/components/light_source_test.gd`, `game/tests/components/interactable_test.gd`, `game/tests/world/forest_scatter_test.gd`

**Interfaces:**
- Consumes: nada.
- Produces:
  - `class_name InputActions`: `const DEFAULTS: Dictionary` (ação → tecla física), `static func register_defaults() -> void` (idempotente). Ações: `move_forward`, `move_back`, `move_left`, `move_right`, `sprint`, `interact`.
  - `class_name MoveMath`: `const MAX_PITCH := 1.4`, `static func wish_velocity(input: Vector2, yaw_basis: Basis, speed: float) -> Vector3`, `static func clamp_pitch(pitch: float) -> float`.
  - `class_name LightSource extends OmniLight3D`: `@export base_energy: float`, `@export burn_time: float`, `var lit: bool`, `var fuel: float`, `func light() -> bool`, `func extinguish() -> void`, `func tick(delta: float) -> void`, `static func flicker_energy(base: float, t: float) -> float`.
  - `class_name Interactable extends StaticBody3D`: `signal interacted(by: Node)`, `@export prompt: String`, `@export enabled: bool`, `func interact(by: Node) -> void`, `func _on_interact(by: Node) -> void` (sobrescrito pelas subclasses).
  - `forest_builder.gd` (sem `class_name`): `static func scatter(count: int, size: float, clearing: float, seed_value: int) -> Array[Transform3D]`.

- [ ] **Step 1: Escrever os testes que falham**

`game/tests/core/input_actions_test.gd`:

```gdscript
extends GdUnitTestSuite


func test_registers_all_actions() -> void:
	InputActions.register_defaults()
	for action: String in InputActions.DEFAULTS:
		assert_bool(InputMap.has_action(action)).is_true()


func test_is_idempotent() -> void:
	InputActions.register_defaults()
	InputActions.register_defaults()
	assert_int(InputMap.action_get_events("interact").size()).is_equal(1)


func test_interact_is_e() -> void:
	InputActions.register_defaults()
	var ev := InputMap.action_get_events("interact")[0] as InputEventKey
	assert_int(ev.physical_keycode).is_equal(KEY_E)
```

`game/tests/player/move_math_test.gd`:

```gdscript
extends GdUnitTestSuite


func test_forward_is_negative_z() -> void:
	var v := MoveMath.wish_velocity(Vector2(0, -1), Basis.IDENTITY, 3.0)
	assert_vector(v).is_equal_approx(Vector3(0, 0, -3), Vector3.ONE * 0.001)


func test_follows_yaw() -> void:
	var yaw := Basis(Vector3.UP, PI / 2.0)
	var v := MoveMath.wish_velocity(Vector2(0, -1), yaw, 3.0)
	assert_vector(v).is_equal_approx(Vector3(-3, 0, 0), Vector3.ONE * 0.001)


func test_diagonal_is_not_faster() -> void:
	var v := MoveMath.wish_velocity(Vector2(1, -1), Basis.IDENTITY, 3.0)
	assert_float(v.length()).is_equal_approx(3.0, 0.001)


func test_no_input_no_movement() -> void:
	assert_vector(MoveMath.wish_velocity(Vector2.ZERO, Basis.IDENTITY, 3.0)).is_equal(Vector3.ZERO)


func test_pitch_is_clamped() -> void:
	assert_float(MoveMath.clamp_pitch(3.0)).is_equal(MoveMath.MAX_PITCH)
	assert_float(MoveMath.clamp_pitch(-3.0)).is_equal(-MoveMath.MAX_PITCH)
	assert_float(MoveMath.clamp_pitch(0.5)).is_equal(0.5)
```

`game/tests/components/light_source_test.gd`:

```gdscript
extends GdUnitTestSuite

var _light: LightSource


func before_test() -> void:
	_light = LightSource.new()
	_light.burn_time = 10.0
	add_child(_light)


func after_test() -> void:
	_light.free()


func test_starts_unlit_and_dark() -> void:
	assert_bool(_light.lit).is_false()
	assert_float(_light.light_energy).is_equal(0.0)


func test_light_turns_on() -> void:
	assert_bool(_light.light()).is_true()
	assert_bool(_light.lit).is_true()
	assert_float(_light.light_energy).is_greater(0.0)


func test_burns_out_and_cannot_relight() -> void:
	_light.light()
	_light.tick(10.5)
	assert_bool(_light.lit).is_false()
	assert_float(_light.light_energy).is_equal(0.0)
	assert_bool(_light.light()).is_false()


func test_unlit_does_not_burn_fuel() -> void:
	_light.tick(5.0)
	assert_float(_light.fuel).is_equal(10.0)


func test_flicker_stays_near_base() -> void:
	for i in 100:
		var e := LightSource.flicker_energy(1.4, i * 0.137)
		assert_float(e).is_between(1.2, 1.6)
```

`game/tests/components/interactable_test.gd`:

```gdscript
extends GdUnitTestSuite

var _thing: Interactable


func before_test() -> void:
	_thing = auto_free(Interactable.new())


func test_emits_when_enabled() -> void:
	var by := auto_free(Node.new())
	var got: Array = []
	_thing.interacted.connect(func(who: Node) -> void: got.append(who))
	_thing.interact(by)
	assert_array(got).contains_exactly([by])


func test_does_nothing_when_disabled() -> void:
	var got: Array = []
	_thing.interacted.connect(func(who: Node) -> void: got.append(who))
	_thing.enabled = false
	_thing.interact(auto_free(Node.new()))
	assert_array(got).is_empty()
```

`game/tests/world/forest_scatter_test.gd`:

```gdscript
extends GdUnitTestSuite

const Forest := preload("res://src/world/forest_builder.gd")


func test_count_and_clearing() -> void:
	var trees := Forest.scatter(200, 100.0, 10.0, 7)
	assert_int(trees.size()).is_equal(200)
	for t in trees:
		assert_float(t.origin.length()).is_greater_equal(10.0)
		assert_float(absf(t.origin.x)).is_less_equal(50.0)
		assert_float(t.origin.y).is_equal(0.0)


func test_same_seed_same_forest() -> void:
	var a := Forest.scatter(50, 100.0, 10.0, 3)
	var b := Forest.scatter(50, 100.0, 10.0, 3)
	for i in 50:
		assert_vector(a[i].origin).is_equal(b[i].origin)


func test_impossible_clearing_returns_empty() -> void:
	assert_int(Forest.scatter(10, 20.0, 15.0, 1).size()).is_equal(0)
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `git add -A; pwsh -File scripts/check.ps1`
Expected: FALHOU (as classes não existem).

- [ ] **Step 3: Implementar**

`game/src/core/input_actions.gd`:

```gdscript
class_name InputActions
extends RefCounted
## Teclas padrão do jogo. Ficam no código para testes e mods usarem os mesmos nomes.

const DEFAULTS := {
	"move_forward": KEY_W,
	"move_back": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"sprint": KEY_SHIFT,
	"interact": KEY_E,
}


static func register_defaults() -> void:
	for action: String in DEFAULTS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = DEFAULTS[action]
		InputMap.action_add_event(action, ev)
```

`game/src/player/move_math.gd`:

```gdscript
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
```

`game/src/components/light_source.gd`:

```gdscript
class_name LightSource
extends OmniLight3D
## Vela ou tocha: acende, apaga, tremula e queima até acabar.

@export var base_energy := 1.4
## Segundos de chama até apagar sozinha.
@export var burn_time := 600.0

var lit := false
var fuel := 0.0

var _t := 0.0


func _ready() -> void:
	fuel = burn_time
	_apply()


func _process(delta: float) -> void:
	tick(delta)


## Acende se ainda houver combustível. Devolve se acendeu.
func light() -> bool:
	if fuel <= 0.0:
		return false
	lit = true
	_apply()
	return true


func extinguish() -> void:
	lit = false
	_apply()


## Avança o tempo da chama. Separado de _process para os testes controlarem o tempo.
func tick(delta: float) -> void:
	if not lit:
		return
	_t += delta
	fuel = maxf(fuel - delta, 0.0)
	if fuel == 0.0:
		extinguish()
		return
	light_energy = flicker_energy(base_energy, _t)


## Duas senoides fora de fase imitam o tremor de uma chama.
static func flicker_energy(base: float, t: float) -> float:
	return base + sin(t * 13.0) * 0.12 + sin(t * 7.3) * 0.08


func _apply() -> void:
	light_energy = base_energy if lit else 0.0
```

`game/src/components/interactable.gd`:

```gdscript
class_name Interactable
extends StaticBody3D
## Algo que o jogador usa olhando para ele e apertando E.
## Subclasses sobrescrevem _on_interact.

signal interacted(by: Node)

## Texto mostrado na mira, depois de "[E]".
@export var prompt := "usar"
@export var enabled := true


func interact(by: Node) -> void:
	if not enabled:
		return
	interacted.emit(by)
	_on_interact(by)


func _on_interact(_by: Node) -> void:
	pass
```

`game/src/world/forest_builder.gd` (primeira parte; a Task 4 completa o arquivo):

```gdscript
extends Node3D
## Floresta em volta da casa: chão, árvores (MultiMesh) e colisão dos troncos.
## Sem modelo de árvore definido, usa uma árvore greybox (tronco e copa).


## Espalha `count` árvores num quadrado de lado `size`, fora de um círculo `clearing`.
## Mesma semente, mesma floresta. Clareira impossível devolve lista vazia.
static func scatter(count: int, size: float, clearing: float, seed_value: int) -> Array[Transform3D]:
	var out: Array[Transform3D] = []
	var half := size / 2.0
	if clearing >= half:
		push_warning("Floresta: clareira de %.1f não cabe numa área de %.1f" % [clearing, size])
		return out
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	while out.size() < count:
		var pos := Vector3(rng.randf_range(-half, half), 0.0, rng.randf_range(-half, half))
		if pos.length() < clearing:
			continue
		var size_factor := rng.randf_range(0.8, 1.4)
		var tree_basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * size_factor)
		out.append(Transform3D(tree_basis, pos))
	return out
```

- [ ] **Step 4: Rodar e ver passar**

Run: `git add -A; pwsh -File scripts/check.ps1`
Expected: `OK: tudo passou`.

- [ ] **Step 5: Commit**

```powershell
git add game
git commit -m "feat: add input actions, movement math, light source and interactable

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: Cena jogável (quarto, vela, carta, floresta e jogador)

**Files:**
- Create: `game/src/player/player.gd`, `game/src/player/player.tscn`, `game/src/world/candle_pickup.gd`, `game/src/world/candle_pickup.tscn`, `game/src/world/letter.gd`, `game/src/world/letter.tscn`, `game/src/world/room.tscn`, `game/src/world/forest.tscn`, `game/src/world/night_environment.tres`, `game/src/main/main.gd`, `game/src/main/main.tscn`
- Modify: `game/src/world/forest_builder.gd` (completar)
- Test: `game/tests/main/main_scene_test.gd`

**Interfaces:**
- Consumes: tudo da Task 3.
- Produces:
  - `class_name Player extends CharacterBody3D`: `var has_candle: bool`, `var reading: bool`, `func equip_candle() -> void`, `func show_text(text: String) -> void`, `func close_text() -> void`, `func try_interact() -> void`, `func current_target() -> Interactable`. Nós: `Head`, `Head/Camera`, `Head/Camera/InteractRay`, `Head/Camera/HandLight` (`LightSource`), `Hud/Prompt`, `Hud/Reader`, `Hud/Reader/Text`.
  - `main.tscn` com os nós `WorldEnvironment`, `Moon`, `Room` (com `Room/Candle` e `Room/Letter`), `Forest` (com `Forest/Trunks`), `Player`.
  - `forest_builder.gd`: `@export tree_scene`, `tree_count`, `area_size`, `clearing_radius`, `scatter_seed`, `ground_material`; `var tree_transforms: Array[Transform3D]`.

- [ ] **Step 1: Escrever os testes que falham**

`game/tests/main/main_scene_test.gd`:

```gdscript
extends GdUnitTestSuite
## Fluxo do despertar: pegar a vela, ler a carta, ficar de pé no chão, árvores com colisão.

const MAIN := "res://src/main/main.tscn"


func test_candle_and_letter_flow() -> void:
	var runner := scene_runner(MAIN)
	var root := runner.scene()
	var player := root.get_node("Player") as Player
	var candle := root.get_node("Room/Candle") as Interactable
	var letter := root.get_node("Room/Letter") as Interactable
	var hand := player.get_node("Head/Camera/HandLight") as LightSource

	assert_bool(player.has_candle).is_false()
	candle.interact(player)
	assert_bool(player.has_candle).is_true()
	assert_bool(hand.lit).is_true()
	assert_bool(candle.enabled).is_false()

	candle.interact(player)  # pegar de novo não faz nada
	assert_bool(player.has_candle).is_true()

	letter.interact(player)
	assert_bool(player.reading).is_true()
	var text := (player.get_node("Hud/Reader/Text") as Label).text
	assert_str(text).contains("Estamos te vendo")
	player.close_text()
	assert_bool(player.reading).is_false()


func test_interact_with_nothing_in_sight_is_safe() -> void:
	var runner := scene_runner(MAIN)
	var player := runner.scene().get_node("Player") as Player
	player.rotation.y = PI  # olha para a parede oposta à mesa
	await runner.simulate_frames(2)
	player.try_interact()
	assert_bool(player.has_candle).is_false()
	assert_bool(player.reading).is_false()


func test_player_stands_on_floor() -> void:
	var runner := scene_runner(MAIN)
	await runner.simulate_frames(90)
	var player := runner.scene().get_node("Player") as Player
	assert_bool(player.is_on_floor()).is_true()
	assert_float(player.global_position.y).is_between(-0.05, 0.3)


func test_forest_has_trunk_collision_per_tree() -> void:
	var runner := scene_runner(MAIN)
	var forest := runner.scene().get_node("Forest")
	var trunks := forest.get_node("Trunks")
	assert_int(trunks.get_child_count()).is_equal(forest.tree_count)
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `git add -A; pwsh -File scripts/check.ps1`
Expected: FALHOU (a cena `main.tscn` não existe).

- [ ] **Step 3: Implementar o jogador**

`game/src/player/player.gd`:

```gdscript
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
```

`game/src/player/player.tscn`:

```ini
[gd_scene format=3]

[ext_resource type="Script" path="res://src/player/player.gd" id="1_player"]
[ext_resource type="Script" path="res://src/components/light_source.gd" id="2_light"]

[sub_resource type="CapsuleShape3D" id="Shape_body"]
radius = 0.35
height = 1.8

[sub_resource type="StandardMaterial3D" id="Mat_wax"]
albedo_color = Color(0.9, 0.86, 0.75, 1)

[sub_resource type="CylinderMesh" id="Mesh_candle"]
material = SubResource("Mat_wax")
top_radius = 0.02
bottom_radius = 0.025
height = 0.12

[sub_resource type="StandardMaterial3D" id="Mat_flame"]
albedo_color = Color(1, 0.7, 0.3, 1)
emission_enabled = true
emission = Color(1, 0.6, 0.25, 1)
emission_energy_multiplier = 3.0

[sub_resource type="SphereMesh" id="Mesh_flame"]
material = SubResource("Mat_flame")
radius = 0.012
height = 0.03

[node name="Player" type="CharacterBody3D"]
script = ExtResource("1_player")

[node name="Collision" type="CollisionShape3D" parent="."]
position = Vector3(0, 0.9, 0)
shape = SubResource("Shape_body")

[node name="Head" type="Node3D" parent="."]
position = Vector3(0, 1.65, 0)

[node name="Camera" type="Camera3D" parent="Head"]
current = true
fov = 75.0

[node name="InteractRay" type="RayCast3D" parent="Head/Camera"]
target_position = Vector3(0, 0, -2)

[node name="HandLight" type="OmniLight3D" parent="Head/Camera"]
position = Vector3(0.25, -0.25, -0.45)
light_color = Color(1, 0.6, 0.3, 1)
omni_range = 6.0
shadow_enabled = true
script = ExtResource("2_light")

[node name="CandleMesh" type="MeshInstance3D" parent="Head/Camera/HandLight"]
position = Vector3(0, -0.08, 0)
mesh = SubResource("Mesh_candle")

[node name="Flame" type="MeshInstance3D" parent="Head/Camera/HandLight"]
mesh = SubResource("Mesh_flame")

[node name="Hud" type="CanvasLayer" parent="."]

[node name="Prompt" type="Label" parent="Hud"]
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -250.0
offset_top = -140.0
offset_right = 250.0
offset_bottom = -100.0
horizontal_alignment = 1

[node name="Reader" type="PanelContainer" parent="Hud"]
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -320.0
offset_top = -160.0
offset_right = 320.0
offset_bottom = 160.0

[node name="Text" type="Label" parent="Hud/Reader"]
horizontal_alignment = 1
vertical_alignment = 1
autowrap_mode = 3
```

- [ ] **Step 4: Implementar a vela e a carta**

`game/src/world/candle_pickup.gd`:

```gdscript
extends Interactable
## Vela sobre a mesa. Ao pegar, vai para a mão do jogador já acesa.


func _on_interact(by: Node) -> void:
	if not by.has_method("equip_candle"):
		return
	by.equip_candle()
	enabled = false
	collision_layer = 0
	hide()
```

`game/src/world/candle_pickup.tscn`:

```ini
[gd_scene format=3]

[ext_resource type="Script" path="res://src/world/candle_pickup.gd" id="1_candle"]

[sub_resource type="BoxShape3D" id="Shape_candle"]
size = Vector3(0.15, 0.16, 0.15)

[sub_resource type="StandardMaterial3D" id="Mat_wax"]
albedo_color = Color(0.9, 0.86, 0.75, 1)

[sub_resource type="CylinderMesh" id="Mesh_candle"]
material = SubResource("Mat_wax")
top_radius = 0.03
bottom_radius = 0.035
height = 0.15

[node name="Candle" type="StaticBody3D"]
script = ExtResource("1_candle")
prompt = "pegar a vela"

[node name="Collision" type="CollisionShape3D" parent="."]
position = Vector3(0, 0.08, 0)
shape = SubResource("Shape_candle")

[node name="Mesh" type="MeshInstance3D" parent="."]
position = Vector3(0, 0.075, 0)
mesh = SubResource("Mesh_candle")
```

`game/src/world/letter.gd`:

```gdscript
extends Interactable
## Carta que o jogador lê. O texto fica na cena e é editável no painel.

@export_multiline var text := ""


func _on_interact(by: Node) -> void:
	if by.has_method("show_text"):
		by.show_text(text)
```

`game/src/world/letter.tscn`:

```ini
[gd_scene format=3]

[ext_resource type="Script" path="res://src/world/letter.gd" id="1_letter"]

[sub_resource type="BoxShape3D" id="Shape_letter"]
size = Vector3(0.25, 0.05, 0.32)

[sub_resource type="StandardMaterial3D" id="Mat_paper"]
albedo_color = Color(0.85, 0.8, 0.68, 1)

[sub_resource type="BoxMesh" id="Mesh_letter"]
material = SubResource("Mat_paper")
size = Vector3(0.21, 0.004, 0.29)

[node name="Letter" type="StaticBody3D"]
script = ExtResource("1_letter")
prompt = "ler a carta"

[node name="Collision" type="CollisionShape3D" parent="."]
position = Vector3(0, 0.02, 0)
shape = SubResource("Shape_letter")

[node name="Mesh" type="MeshInstance3D" parent="."]
position = Vector3(0, 0.002, 0)
mesh = SubResource("Mesh_letter")
```

- [ ] **Step 5: Implementar o quarto (CSG, editável no editor)**

`game/src/world/room.tscn`:

```ini
[gd_scene format=3]

[ext_resource type="PackedScene" path="res://src/world/candle_pickup.tscn" id="1_candle"]
[ext_resource type="PackedScene" path="res://src/world/letter.tscn" id="2_letter"]

[sub_resource type="StandardMaterial3D" id="Mat_wood"]
albedo_color = Color(0.22, 0.16, 0.11, 1)
roughness = 0.9

[sub_resource type="StandardMaterial3D" id="Mat_cloth"]
albedo_color = Color(0.3, 0.27, 0.24, 1)
roughness = 1.0

[node name="Room" type="Node3D"]

[node name="Shell" type="CSGCombiner3D" parent="."]
use_collision = true

[node name="Outer" type="CSGBox3D" parent="Shell"]
position = Vector3(0, 1.5, 0)
size = Vector3(6, 3.2, 5)
material = SubResource("Mat_wood")

[node name="Inner" type="CSGBox3D" parent="Shell"]
position = Vector3(0, 1.4, 0)
operation = 2
size = Vector3(5.6, 2.8, 4.6)
material = SubResource("Mat_wood")

[node name="Door" type="CSGBox3D" parent="Shell"]
position = Vector3(0, 1, 2.5)
operation = 2
size = Vector3(1, 2, 0.6)

[node name="Window" type="CSGBox3D" parent="Shell"]
position = Vector3(-2.9, 1.6, 0)
operation = 2
size = Vector3(0.6, 0.9, 1.2)

[node name="Bed" type="CSGBox3D" parent="Shell"]
position = Vector3(2.2, 0.25, -1.2)
size = Vector3(1, 0.5, 2)
material = SubResource("Mat_cloth")

[node name="Table" type="CSGBox3D" parent="Shell"]
position = Vector3(-1.8, 0.375, -1.6)
size = Vector3(0.8, 0.75, 0.6)
material = SubResource("Mat_wood")

[node name="Candle" parent="." instance=ExtResource("1_candle")]
position = Vector3(-1.95, 0.75, -1.6)

[node name="Letter" parent="." instance=ExtResource("2_letter")]
position = Vector3(-1.6, 0.752, -1.55)
text = "Estamos te vendo.
Estamos te observando.
Tome cuidado com suas ações."
```

- [ ] **Step 6: Completar a floresta**

Substituir o conteúdo de `game/src/world/forest_builder.gd` por:

```gdscript
extends Node3D
## Floresta em volta da casa: chão, árvores (MultiMesh) e colisão dos troncos.
## Sem modelo de árvore definido, usa uma árvore greybox (tronco e copa).

## Modelo de árvore (.glb). Vazio = árvore greybox.
@export var tree_scene: PackedScene
@export var tree_count := 600
@export var area_size := 120.0
@export var clearing_radius := 10.0
@export var scatter_seed := 42
## Material do chão. Vazio = cor de terra escura.
@export var ground_material: Material

var tree_transforms: Array[Transform3D] = []


func _ready() -> void:
	tree_transforms = scatter(tree_count, area_size, clearing_radius, scatter_seed)
	_build_ground()
	_build_trees()
	_build_trunk_collision()


## Espalha `count` árvores num quadrado de lado `size`, fora de um círculo `clearing`.
## Mesma semente, mesma floresta. Clareira impossível devolve lista vazia.
static func scatter(count: int, size: float, clearing: float, seed_value: int) -> Array[Transform3D]:
	var out: Array[Transform3D] = []
	var half := size / 2.0
	if clearing >= half:
		push_warning("Floresta: clareira de %.1f não cabe numa área de %.1f" % [clearing, size])
		return out
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	while out.size() < count:
		var pos := Vector3(rng.randf_range(-half, half), 0.0, rng.randf_range(-half, half))
		if pos.length() < clearing:
			continue
		var size_factor := rng.randf_range(0.8, 1.4)
		var tree_basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * size_factor)
		out.append(Transform3D(tree_basis, pos))
	return out


static func _flat_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	return mat


## Posição de `node` relativa a `root`, sem precisar estar na árvore de cena.
static func _relative_transform(root: Node3D, node: Node3D) -> Transform3D:
	var t := Transform3D.IDENTITY
	var current: Node = node
	while current != root and current is Node3D:
		t = (current as Node3D).transform * t
		current = current.get_parent()
	return t


func _build_ground() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(area_size, area_size)
	var mesh := MeshInstance3D.new()
	mesh.name = "GroundMesh"
	mesh.mesh = plane
	mesh.position.y = -0.01  # abaixo do piso do quarto, evita tremulação
	mesh.material_override = (
		ground_material if ground_material else _flat_material(Color(0.08, 0.07, 0.05))
	)
	add_child(mesh)
	var box := BoxShape3D.new()
	box.size = Vector3(area_size, 1.0, area_size)
	var shape := CollisionShape3D.new()
	shape.shape = box
	shape.position.y = -0.5
	var body := StaticBody3D.new()
	body.name = "Ground"
	body.add_child(shape)
	add_child(body)


## Cada parte da árvore: {"mesh": Mesh, "offset": Transform3D, "material": Material ou null}.
func _tree_parts() -> Array[Dictionary]:
	var parts: Array[Dictionary] = []
	if tree_scene == null:
		var trunk := CylinderMesh.new()
		trunk.top_radius = 0.15
		trunk.bottom_radius = 0.25
		trunk.height = 4.0
		var crown := CylinderMesh.new()
		crown.top_radius = 0.0
		crown.bottom_radius = 1.6
		crown.height = 5.0
		parts.append(
			{
				"mesh": trunk,
				"offset": Transform3D(Basis.IDENTITY, Vector3(0, 2, 0)),
				"material": _flat_material(Color(0.12, 0.09, 0.07)),
			}
		)
		parts.append(
			{
				"mesh": crown,
				"offset": Transform3D(Basis.IDENTITY, Vector3(0, 5.5, 0)),
				"material": _flat_material(Color(0.04, 0.08, 0.05)),
			}
		)
		return parts
	var root := tree_scene.instantiate() as Node3D
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		parts.append({"mesh": mi.mesh, "offset": _relative_transform(root, mi), "material": null})
	root.free()
	return parts


func _build_trees() -> void:
	for part in _tree_parts():
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = part["mesh"]
		mm.instance_count = tree_transforms.size()
		var offset: Transform3D = part["offset"]
		for i in tree_transforms.size():
			mm.set_instance_transform(i, tree_transforms[i] * offset)
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		if part["material"] != null:
			mmi.material_override = part["material"]
		add_child(mmi)


func _build_trunk_collision() -> void:
	var shape := CylinderShape3D.new()
	shape.radius = 0.3
	shape.height = 4.0
	var body := StaticBody3D.new()
	body.name = "Trunks"
	for t in tree_transforms:
		var col := CollisionShape3D.new()
		col.shape = shape
		col.position = t.origin + Vector3(0, 2, 0)
		body.add_child(col)
	add_child(body)
```

`game/src/world/forest.tscn`:

```ini
[gd_scene format=3]

[ext_resource type="Script" path="res://src/world/forest_builder.gd" id="1_forest"]

[node name="Forest" type="Node3D"]
script = ExtResource("1_forest")
```

- [ ] **Step 7: Ambiente noturno e cena principal**

`game/src/world/night_environment.tres` (preset visual da área; editável no painel):

```ini
[gd_resource type="Environment" format=3]

[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_night"]
sky_top_color = Color(0.02, 0.03, 0.06, 1)
sky_horizon_color = Color(0.05, 0.06, 0.09, 1)
ground_bottom_color = Color(0.01, 0.01, 0.02, 1)
ground_horizon_color = Color(0.05, 0.06, 0.09, 1)

[sub_resource type="Sky" id="Sky_night"]
sky_material = SubResource("ProceduralSkyMaterial_night")

[resource]
background_mode = 2
sky = SubResource("Sky_night")
ambient_light_source = 3
ambient_light_energy = 0.15
tonemap_mode = 3
ssao_enabled = true
sdfgi_enabled = true
glow_enabled = true
volumetric_fog_enabled = true
volumetric_fog_density = 0.035
volumetric_fog_albedo = Color(0.6, 0.65, 0.75, 1)
```

Valores de enum usados: `background_mode = 2` é céu; `ambient_light_source = 3` é luz do céu; `tonemap_mode = 3` é ACES.

`game/src/main/main.gd`:

```gdscript
extends Node3D
## Cena jogável atual: o quarto do despertar e a floresta em volta.
## Com o argumento "-- --benchmark", mede o fps num trajeto fixo e fecha.


func _enter_tree() -> void:
	InputActions.register_defaults()


func _ready() -> void:
	if "--benchmark" in OS.get_cmdline_user_args():
		var probe := Camera3D.new()
		probe.set_script(load("res://tools/fps_probe.gd"))
		add_child(probe)
```

`game/src/main/main.tscn`:

```ini
[gd_scene format=3]

[ext_resource type="Script" path="res://src/main/main.gd" id="1_main"]
[ext_resource type="Environment" path="res://src/world/night_environment.tres" id="2_env"]
[ext_resource type="PackedScene" path="res://src/world/room.tscn" id="3_room"]
[ext_resource type="PackedScene" path="res://src/world/forest.tscn" id="4_forest"]
[ext_resource type="PackedScene" path="res://src/player/player.tscn" id="5_player"]

[node name="Main" type="Node3D"]
script = ExtResource("1_main")

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = ExtResource("2_env")

[node name="Moon" type="DirectionalLight3D" parent="."]
rotation = Vector3(-0.6, -1.2, 0)
light_color = Color(0.6, 0.7, 1, 1)
light_energy = 0.35
light_volumetric_fog_energy = 1.5
shadow_enabled = true

[node name="Room" parent="." instance=ExtResource("3_room")]

[node name="Forest" parent="." instance=ExtResource("4_forest")]

[node name="Player" parent="." instance=ExtResource("5_player")]
position = Vector3(1.3, 0.05, -1.2)
rotation = Vector3(0, 1.5708, 0)
```

O jogador nasce ao lado da cama, virado para a mesa (rotação de 90 graus aponta a câmera para -X).

- [ ] **Step 8: Rodar e ver passar**

Run: `git add -A; pwsh -File scripts/check.ps1`
Expected: `OK: tudo passou`.

Se `test_player_stands_on_floor` falhar porque a física não rodou nos quadros simulados, trocar `simulate_frames(90)` por `await runner.simulate_frames(90, 16)` (90 quadros de 16 ms). Se `position`/`rotation` nos `.tscn` não forem aplicados, trocar por `transform = Transform3D(...)` equivalente.

- [ ] **Step 9: Jogar de verdade**

Run: `& $env:GODOT_BIN --path game` (ou o caminho padrão do Godot)

Conferir à mão: acorda no quarto escuro; a mira mostra `[E] pegar a vela` na mesa; a vela acende na mão e ilumina; `[E] ler a carta` mostra o texto; E ou Esc fecha; dá para sair pela porta e andar na floresta sem atravessar árvores. Tirar 3 capturas (F12 não existe ainda; usar a captura do Windows, `Win+Shift+S`) para o relatório.

- [ ] **Step 10: Commit**

```powershell
git add game
git commit -m "feat: add first playable wake-up scene with candle, letter and forest

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Medição, playtest com o Gustavo e assets

**Files:**
- Create: `game/tools/fps_probe.gd`, `docs/playtests/2026-10-primeiro-jogavel.md`
- Modify (conforme o retorno): `game/src/world/night_environment.tres`, `game/src/main/main.tscn`, `game/src/world/room.tscn`, `game/src/world/forest.tscn`

**Interfaces:**
- Consumes: `main.tscn` (Task 4).
- Produces: `godot --path game -- --benchmark` grava `user://benchmark.txt` com `fps_medio` e `fps_1pct`.

- [ ] **Step 1: Escrever a câmera de medição**

`game/tools/fps_probe.gd`:

```gdscript
extends Camera3D
## Benchmark: circula a casa por 20 s, mede fps, grava em user://benchmark.txt e fecha.

const DURATION := 20.0
const RADIUS := 25.0

var _t := 0.0
var _samples: PackedFloat32Array = []


func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	current = true


func _process(delta: float) -> void:
	_t += delta
	position = Vector3(cos(_t * 0.3) * RADIUS, 1.7, sin(_t * 0.3) * RADIUS)
	look_at(Vector3(0.0, 1.5, 0.0))
	if _t > 1.0:  # o primeiro segundo é carregamento
		_samples.append(1.0 / delta)
	if _t >= DURATION:
		_finish()


func _finish() -> void:
	var sorted := _samples.duplicate()
	sorted.sort()
	var total := 0.0
	for s in _samples:
		total += s
	var text := (
		"fps_medio=%.1f fps_1pct=%.1f amostras=%d"
		% [total / _samples.size(), sorted[int(sorted.size() * 0.01)], _samples.size()]
	)
	print(text)
	var f := FileAccess.open("user://benchmark.txt", FileAccess.WRITE)
	f.store_line(text)
	f.close()
	get_tree().quit()
```

- [ ] **Step 2: Medir**

Run: `& $env:GODOT_BIN --path game --resolution 1920x1080 -- --benchmark`
Expected: `fps_medio=... fps_1pct=...`. Critério: média ≥ 60 e 1% ≥ 45.

Se falhar, reduzir uma coisa por vez e medir de novo: `tree_count` para 300 no `forest.tscn`; `sdfgi_enabled = false`; `volumetric_fog_density` para 0.02.

- [ ] **Step 3: Playtest com o Gustavo**

Pedir que ele jogue (`& $env:GODOT_BIN --path game`) e responda: o clima funciona para o começo do Capítulo 1? O que falta ou incomoda? Ajustar névoa, lua, vela, posição dos objetos e velocidade de andar conforme o retorno. No máximo 2 rodadas; se não convergir, aplicar o "ponto de virada" do CLAUDE.md.

- [ ] **Step 4: Levantar assets candidatos**

Pesquisar e registrar (sem baixar) no relatório, com link e licença:
- árvore, textura de chão e céu noturno do Poly Haven (CC0);
- 2 opções de lobo animado e 2 de lobisomem (CC0 ou CC-BY);
- som ambiente noturno, risada infantil distante e 3 faixas de música sombria (CC0 ou CC-BY).

Se o Gustavo quiser ver a arte real já neste plano, pedir confirmação de cada download (nome, origem, tamanho), salvar em `game/assets/`, apontar `tree_scene` e `ground_material` no `forest.tscn` e registrar no `CREDITS.md` (Task 6).

- [ ] **Step 5: Escrever o relatório e commitar**

`docs/playtests/2026-10-primeiro-jogavel.md` com as seções: o que foi testado; desempenho (`fps_medio`, `fps_1pct`, ajustes feitos); retorno do Gustavo (citação curta); mudanças feitas; assets candidatos (tabela: tipo, nome, link, licença); pendências para os próximos planos. Copiar as capturas para `docs/playtests/img/`.

```powershell
git add game docs/playtests
git commit -m "feat: add fps benchmark and first playtest report

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Documentação, revisão, GitHub e merge

**Files:**
- Create: `README.md`, `CLAUDE.md`, `CREDITS.md`, `docs/COMO-EDITAR.md`
- Modify: `ROADMAP.md`

- [ ] **Step 1: Escrever a documentação**

`README.md` (portfólio): problema que o jogo resolve em 2 frases; o que já dá para jogar e os controles; tecnologias e por quê (tabela curta, link para `docs/BIBLIA.md`); como rodar (pré-requisitos Godot 4.7.2 e Python 3.12; `pwsh -File scripts/check.ps1`; `godot --path game`); capturas do playtest; estado atual (link para `ROADMAP.md`).

`docs/COMO-EDITAR.md`, tabela "quero mudar X → onde":
- texto da carta → `game/src/world/room.tscn`, nó `Letter`, propriedade `text`;
- posição da cama, mesa, porta e janela → `game/src/world/room.tscn` (nós CSG);
- quantidade e tamanho da floresta, modelo de árvore → `game/src/world/forest.tscn` (propriedades do nó `Forest`);
- névoa, céu e luz ambiente → `game/src/world/night_environment.tres`;
- cor e força da lua → `game/src/main/main.tscn`, nó `Moon`;
- velocidade de andar e correr, sensibilidade do mouse → `game/src/player/player.tscn` (propriedades do `Player`);
- duração e brilho da vela → `game/src/player/player.tscn`, nó `HandLight`;
- teclas → `game/src/core/input_actions.gd`.

Uma linha no topo: "Este mapa cresce a cada plano."

`CREDITS.md`: título, a frase "Todo asset de terceiros usado no jogo aparece aqui com fonte e licença", e as linhas de Godot (MIT) e GdUnit4 (MIT), mais os assets do Step 4 da Task 5, se entraram.

- [ ] **Step 2: Gerar o `CLAUDE.md` do projeto**

Rodar `/init` na pasta do projeto e ajustar para conter: stack (Godot 4.7.2, GDScript tipado, GdUnit4, gdtoolkit); comandos (`scripts/check.ps1`, `godot --path game`, `godot --path game -- --benchmark`); regra "greybox primeiro, arte trocada por propriedade"; caminho do Godot (`GODOT_BIN`); alvo de deploy (itch.io, só com confirmação); links para `docs/BIBLIA.md` e para o índice de planos.

- [ ] **Step 3: Atualizar o `ROADMAP.md`**

"Feito": primeiro jogável (acordar, vela, carta, floresta greybox), testes e benchmark. "Em andamento": Plano 02 (dados e mods).

- [ ] **Step 4: Rodar tudo e commitar**

Run: `git add -A; pwsh -File scripts/check.ps1`
Expected: `OK: tudo passou`.

```powershell
git add README.md CLAUDE.md CREDITS.md ROADMAP.md docs
git commit -m "docs: add readme, editing map, credits and project instructions

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 5: Revisão independente**

Disparar o subagente `feature-dev:code-reviewer` com o diff `git diff main...feat/first-playable`, pedindo foco em: bugs do controle do jogador, caminhos de nó frágeis entre script e cena, testes que passam sem exercitar o código e problemas de desempenho na floresta. Corrigir cada bug apontado, com teste novo, e rodar `check.ps1` de novo. Achado não corrigido vai para a descrição do PR com o trecho e o motivo.

- [ ] **Step 6: Criar o repositório no GitHub (com confirmação)**

Perguntar ao Gustavo: "Crio o repositório `ashen-vigil` no GitHub como público (portfólio) ou privado?". Só depois do "sim":

```powershell
gh repo create ashen-vigil --public --source . --remote origin
git push -u origin main
git push -u origin feat/first-playable
```

- [ ] **Step 7: Abrir o PR**

Escrever `$env:TEMP\pr-body.md` com a ferramenta Write: resumo; comandos rodados (`scripts/check.ps1`, benchmark) com o resultado; número de testes; retorno do playtest; achados da revisão e o que foi feito com cada um; **o que não foi testado** (GTX 1060; entrada de mouse e teclado nos testes automáticos, que rodam sem tela; build exportado); e a linha final `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.

```powershell
gh pr create --base main --head feat/first-playable --title "feat: first playable wake-up scene" --body-file "$env:TEMP\pr-body.md"
```

- [ ] **Step 8: Merge seguro**

```powershell
git fetch origin
git merge origin/main
pwsh -File scripts/check.ps1
$sha = git rev-parse HEAD
git push
gh pr merge --squash --match-head-commit $sha --delete-branch
```
Expected: PR mesclado; branch apagada.

- [ ] **Step 9: Relatório e próximo plano**

Relatório de 2 a 3 linhas ao Gustavo (o que mudou, o que vem a seguir). Oferecer gravar `NOTAS.md`. Próximo: revisar o Plano 02 (dados e mods) contra o código real e executá-lo.
