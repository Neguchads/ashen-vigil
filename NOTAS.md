# NOTAS — ashen-vigil (2026-10-21)

## Feito
- Modo mvp: spec do Capítulo 1 (`docs/superpowers/specs/2026-10-15-ashen-vigil-design.md`), bíblia do projeto, história, bíblia do mundo e índice dos 10 planos.
- Plano 01 (primeiro jogável, greybox): Godot 4.7.2, GdUnit4, `scripts/check.ps1`, movimento, vela, carta, quarto e floresta. Testes com mutação e benchmark de fps (CPU x GPU). PR #1 mergeado em 16/10.
- Commit de combate e configurações (`e22d206`) veio de outra sessão ou ferramenta.

## Falta
- **Achados da revisão independente do Plano 01 (20/10, depois do merge), ainda abertos na `main`:**
  - Importantes:
    1. A chama continua visível depois que a vela apaga.
    2. Nenhum teste aperta E/Esc de verdade (`_unhandled_input` sem teste).
    3. O jogador cai para fora do mapa (sem parede nem respawn).
    4. (O quarto importante era a varredura de segredos com `--untracked`, já corrigido na `main`.)
  - Menores: ações de entrada só registradas pela `main.tscn`; o painel da carta engole o clique; `AimAt` quebra com alvo na vertical; falta `#Requires -Version 7` no `check.ps1`.
- Playtest do primeiro jogável pelo dono (ROADMAP "Em andamento").
- Mudanças locais sem commit: `.gitattributes` modificado, `Jogar.bat` e `ashen-vigil.zip` novos. Decidir: o zip não deve ir para o git; `Jogar.bat` talvez sim.
- Este `NOTAS.md` ainda não está commitado.

## Decisões
- Greybox, e cada plano termina jogável: o dono vê o jogo andando cedo, e a arte final entra depois sem refazer o resto.
- Jogo base como "mod zero": conteúdo carregado por registro de IDs e fichas `.tres`. Se o jogo base funciona por esse caminho, os mods também funcionam.
- Roblox/Garry's Mod adiado: é outro produto, do tamanho do RPG ou maior. A arquitetura só deixa o caminho aberto.
