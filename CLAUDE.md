# Ashen Vigil

RPG de fantasia sombria em Godot, primeira pessoa, coop. Visão, história e arquitetura: `docs/BIBLIA.md`. Spec: `docs/superpowers/specs/2026-10-15-ashen-vigil-design.md`. Planos e ordem de entrega: `docs/superpowers/plans/2026-10-15-00-indice.md`.

## Stack

- Godot 4.7.2, renderizador Forward+, GDScript com tipagem estática (avisos de tipo são erro).
- Testes: GdUnit4 6.2.2, vendorizado em `game/addons/gdUnit4` (não editar).
- Lint e formatação: gdtoolkit 4.5.0 no `.venv` (linhas até 100 caracteres).

## Comandos

```powershell
pwsh -File scripts/check.ps1                     # formatação, lint, segredos, importação e testes
.\.venv\Scripts\gdformat.exe game\src game\tests game\tools   # corrige a formatação
& $env:GODOT_BIN --path game                     # jogar
& $env:GODOT_BIN --path game --resolution 1920x1080 --always-on-top -- --benchmark   # medir fps
```

`GODOT_BIN` padrão: `A:\AI\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe`.

## Regras do projeto

- Jogável desde o começo: cada plano termina com algo novo para jogar.
- Greybox primeiro. A arte real entra trocando propriedades (`tree_scene`, materiais, cenas), não reescrevendo código.
- Números e textos em `@export` ou `.tres`, editáveis no painel; registre o caminho em `docs/COMO-EDITAR.md`.
- Lógica pura em funções estáticas pequenas e testadas; cenas testadas com `scene_runner`.
- Não usar `-d` no comando de testes do Godot: em erro de parse ele abre o depurador e trava.
- O benchmark só vale com a janela do jogo em primeiro plano (o Windows desacelera janelas em segundo plano).
- Todo asset novo entra no `CREDITS.md` com fonte e licença (só CC0, CC-BY ou licença que permita qualquer motor).
- Publicar no itch.io só com confirmação.
