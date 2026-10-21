# NOTAS — ashen-vigil (2026-10-21)

## Feito
- Modo mvp: spec do Capítulo 1 (`docs/superpowers/specs/2026-10-15-ashen-vigil-design.md`), bíblia do projeto, história, bíblia do mundo e índice dos 10 planos.
- Plano 01 (primeiro jogável, greybox): Godot 4.7.2, GdUnit4, `scripts/check.ps1`, movimento, vela, carta, quarto e floresta. Testes com mutação e benchmark de fps (CPU x GPU).
- Plano 02 (dados e mods: adaga pelo registro, mod de exemplo em `.pck`, empacotador) e a fatia de combate e configurações (bloqueio/esquiva, vida/stamina, lobo, viajante, menu de pausa; 93 testes, `docs/playtests/2026-10-combate-e-configuracoes.md`).
- Tudo isso entrou junto no PR #1 (mergeado em 16/10); o combate é o commit `e22d206`, o último do PR.

## Falta
- **Achados da revisão independente do Plano 01 (20/10, depois do merge), conferidos no código da `main` em 21/10 e ainda abertos:**
  - Importantes:
    1. A chama continua visível depois que a vela apaga: `extinguish()` em `light_source.gd` só zera `light_energy`, e nada esconde o nó `Flame` do `player.tscn`.
    2. Nenhum teste aperta E/Esc de verdade: `_unhandled_input` (`player.gd`) e o `ui_cancel` do `pause_menu.gd` só são testados por chamada direta.
    3. O jogador cai para fora do mapa: o chão do `forest_builder.gd` é finito (120 x 120), sem parede de borda nem respawn.
    4. (O quarto importante era a varredura de segredos com `--untracked`, já corrigido na `main`.)
  - Menores: ações de entrada só registradas pela `main.tscn`; o painel da carta engole o clique; `AimAt` quebra com alvo na vertical; falta `#Requires -Version 7` no `check.ps1`.
- Playtest do primeiro jogável pelo dono (ROADMAP "Em andamento").
- Mudanças locais sem commit: `.gitattributes` modificado, `Jogar.bat` e `ashen-vigil.zip` novos. Decidir: o zip não deve ir para o git; `Jogar.bat` talvez sim.

## Decisões
- Greybox, e cada plano termina jogável: o dono vê o jogo andando cedo, e a arte final entra depois sem refazer o resto.
- Jogo base como "mod zero": conteúdo carregado por registro de IDs e fichas `.tres`. Se o jogo base funciona por esse caminho, os mods também funcionam.
- Roblox/Garry's Mod adiado: é outro produto, do tamanho do RPG ou maior. A arquitetura só deixa o caminho aberto.
