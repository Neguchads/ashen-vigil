# Combate, configurações e encontro na floresta

Escopo solicitado em 2026-10-16: animações, ações, menu de configurações,
combate, interações, lobo distante caído e ferido, biblioteca gratuita de assets.
Preservar quarto, carta, vela e registro de conteúdo já implementados.

## Entrega verificável

- [x] Ataque com adaga, bloqueio e esquiva gastam stamina; acertos exigem alcance
  e linha de visão. Não atacar lendo ou com o jogo pausado.
- [x] Animação de golpe e movimento da arma, ações animadas das criaturas.
- [x] Lobo hostil com perseguição, ataque, dano e morte; outro ferido, caído e
  distante, com interação para poupar. A escolha vale para a sessão atual.
- [x] Menu por Esc pausa o mundo, permite retomar/recomeçar e oferece volume,
  sensibilidade, FOV, tela cheia, VSync, qualidade e movimento reduzido.
  Configurações salvas em `user://settings.cfg`.
- [x] Biblioteca CC0 com origem, licença, tamanho e SHA256. Integrar o lobo e
  alguns modelos ao jogo; manter o restante disponível como biblioteca.
- [x] Testes do projeto, importação, execução renderizada, revisão e capturas.

Resultado: 93 testes em 19 suítes, lint/formatação/importação/segredos aprovados;
roteiro renderizado sem falhas. Revisão corrigiu o cancelamento da recuperação
do golpe pela pausa. Relatório: `docs/playtests/2026-10-combate-e-configuracoes.md`.

## Implementação

`CombatVitals` mantém vida/stamina. `CombatController`, filho do jogador,
coordena ataque/bloqueio/esquiva. `EnemyDef` fornece números e modelo por ID;
`Wolf` usa esses dados e animações importadas. `GameSettings` mantém e aplica
as preferências; `PauseMenu` é a interface nativa do Godot. Acrescentar
somente as cenas necessárias para os encontros e cenário.

Sem novas bibliotecas de código. Os pacotes gratuitos são assets, com licença
registrada. Coop, inventário completo, relógio do mundo, diário persistente e
exportação/publicação não entram nesta entrega.

## Assets

O Google Drive do Ultimate Animated Animal Pack respondeu com cota esgotada.
Usar a publicação do próprio Quaternius no OpenGameArt e os repositórios oficiais
KayKit. Download solicitado explicitamente pelo usuário nesta sessão.
