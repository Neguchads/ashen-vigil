# Validação: combate, configurações e encontros (2026-10-16)

## Entrega

Ataque animado com a adaga, bloqueio frontal e esquiva direcional. Golpes
consomem stamina, têm preparação e recuperação, só acertam uma vez e respeitam
alcance e obstáculos. Correr também consome stamina. Vida e stamina aparecem
no canto inferior esquerdo após equipar a arma ou receber dano.

Um lobo hostil fica na trilha. Mais adiante, a cerca de 29 m da origem do mapa,
há outro lobo caído e ferido. Ele permanece passivo: **E** o poupa; ataques podem
matá-lo. A escolha pertence à sessão e é apagada ao recomeçar.

O viajante de armadura próximo do poço tem animação de descanso e uma conversa
curta. A construção e o poço usam modelos baixados; o cenário restante ainda
combina esses modelos com formas provisórias.

![Encontro com o lobo](img/combate-lobo.png)

![Lobo ferido distante](img/lobo-ferido.png)

![Viajante e cenário](img/viajante-e-cenario.png)

## Menu e configurações

**Esc** fecha a leitura; fora da leitura, pausa/retoma o mundo. O menu permite
recomeçar, sair, alterar sensibilidade, FOV, volume, tela cheia, VSync, qualidade
e movimento reduzido. Sliders mostram os efeitos imediatamente. O botão
**Salvar configurações** grava `user://settings.cfg`; há retorno visível para
sucesso ou erro. Os controles aceitam navegação por teclado e rolagem.

Após morrer, o menu oferece **Despertar novamente**. Reiniciar recarrega a cena
e restaura inimigos, itens e vida. Isso ainda não é o sistema narrativo completo
de ciclos temporais, relógio e diário.

![Menu de pausa e configurações](img/configuracoes.png)

## Verificações executadas

- `pwsh -File scripts/check.ps1`: **93 testes em 19 suítes**, zero erros, falhas,
  testes pulados ou nós órfãos. Formatação, lint, importação e varredura de
  segredos passaram. Havia 76 testes antes desta etapa.
- Integração: gasto e recuperação de stamina, bloqueio frontal, esquiva,
  preparação do golpe, um acerto por ataque, parede bloqueando golpes,
  inimigo fora do alcance, dano causado pelo lobo, morte/queda, poupar/matar
  o ferido e corredor livre de troncos.
- Configurações: gravação/leitura real de arquivo temporário; controles do menu
  alterando FOV, sensibilidade, SDFGI e névoa volumétrica da cena.
- Execução renderizada em Forward+, RTX 3060 e 1280×720: quatro capturas,
  movimento de ataque, interação com viajante, poupar lobo, pausa física,
  retomada do mouse, morte e reinício restaurando vida e encontro. Todas as
  verificações do roteiro retornaram sucesso, sem erros no log.
- Inicialização normal da cena principal em modo headless: sem erro de script.
- Revisão independente: corrigido o cancelamento indevido da recuperação do
  golpe ao pausar/retomar. O teste falhou antes e passou depois da correção.
- Capturas conferidas: escala do lobo, orientação dos modelos, encaixe do menu
  na janela e acentuação em português.

Os testes headless não reproduzem a captura física do cursor do Windows;
pausa e restauração do cursor também foram conferidas na execução renderizada.
O tempo de preparação do ataque foi testado com entrada e tempo controlados,
pois contar quadros de renderização não garante igual quantidade de passos físicos.

## Assets

Cinco pacotes CC0 baixados, **53,4 MiB transferidos**. A seleção carregada pelo
jogo tem cerca de 4,13 MiB antes dos caches. Licenças e origens: `CREDITS.md`;
catálogo: `docs/ASSETS.md`; arquivos completos: `asset_library/`.

O lobo original tem descanso e caminhada. Avanço de ataque e queda foram
implementados com transformações no jogo. O viajante usa o clipe de descanso
do personagem humano. Outros clipes e criaturas estão disponíveis na biblioteca,
mas não foram ligados à lógica atual.

## Como conferir

```powershell
& 'A:\AI\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --path game
```

Pegue a vela e a adaga. Mouse esquerdo ataca; direito bloqueia; Espaço esquiva;
Shift corre; F alterna a chama. Procure o viajante perto do poço, depois siga
a trilha entre as árvores para os dois lobos. Abra Esc e altere o campo de visão
para observar a aplicação imediata; salve as configurações se quiser mantê-las.

## Limites

Não houve playtest humano, benchmark novo de fps, teste em GTX 1060, teste
multiplayer ou exportação de executável. O equilíbrio de dano, alcance e esquiva
precisa de avaliação jogando. Sem sistema de armadura/inventário, áudio de combate,
persistência narrativa ou arte final. Os modelos baixados são estilizados.
Não foram feitos commit, push, PR ou publicação.
