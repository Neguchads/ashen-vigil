# Playtest: primeiro jogável (2026-10-16)

## O que foi testado

Cena do despertar em greybox: o jogador acorda no quarto escuro, pega a vela, lê a carta e sai para a floresta à noite. Controles: WASD, mouse, Shift, E, Esc.

## Desempenho (RTX 3060, 1080p, Forward+)

Medido com `godot --path game --resolution 1920x1080 --always-on-top -- --benchmark` (câmera circulando a casa por 20 s).

| Rodada | Janela | fps médio | 1% mais baixo | Tempo de GPU |
|---|---|---|---|---|
| 1 | atrás de outras janelas | 47,5 | 19,5 | — |
| 2 | sempre na frente | 59,7 | 56,6 | 5,5 ms |

- **Conclusão:** a cena cabe com folga. 5,5 ms de GPU por quadro permitem cerca de 180 fps; os 59,7 fps estão presos aos 60 Hz do monitor.
- **Armadilha de medição:** com a janela do jogo atrás de outras, o Windows 11 reduz o ritmo do processo e os números caem para 20 a 47 fps, sem relação com a cena. Desligar SDFGI ou a névoa não mudou nada nesse modo. O benchmark só vale com a janela em primeiro plano.
- Nenhum ajuste de qualidade foi necessário; SDFGI, névoa volumétrica e 600 árvores continuam ligados.

## Ajustes feitos durante o teste

- **Luar pela janela.** A primeira imagem do quarto saiu totalmente preta. Um feixe de luar (`MoonBeam`) entra pela janela e ilumina a mesa com a vela e a carta. Isso também guia o jogador sem tutorial.

## Retorno do Gustavo

_Preencher depois de ele jogar._

## Assets candidatos (pesquisa, nada baixado)

| Tipo | Nome | Link | Licença | Observação |
|---|---|---|---|---|
| Lobo | Winter wolf + normal wolf | https://opengameart.org/content/winter-wolf-normal-wolf | CC-BY-SA 3.0 | Tem ataque, dano, morte, corrida; vem em `.blend` (converter para GLB). SA exige compartilhar derivados com a mesma licença |
| Lobo | Low Poly Wolf (ManNeko) | https://manneko.itch.io/low-poly-wolf | Uso comercial livre (licença própria) | GLB, mas sem ataque e sem morte |
| Lobisomem | Werewolf (Sloyd) | https://www.sloyd.ai/free-3d-models/model/werewolf-zeb1bwog | CC-BY 4.0 | Não diz se tem esqueleto e animação; conferir |
| Lobisomem | Busca no Sketchfab | https://sketchfab.com/search?features=downloadable&licenses=322a749bcfa841b29dff1e8a1bb74b0b&q=werewolf | CC-BY (filtro) | Nada certo ainda; plano B do spec: só silhueta e som |
| Música | Paranoid Truth (Tsorthan Grove) | https://opengameart.org/content/paranoid-truth | CC0 | Drone sombrio, tensão |
| Música | Horror Atmosphere (SubspaceAudio) | https://opengameart.org/node/18036 | CC0 | Atmosfera em loop, 5:23, sem melodia |
| Música | Dark Cavern Ambient (Paul Wortmann) | https://opengameart.org/node/79273 | CC0 | Dois loops; bom para a caverna |
| Som | Free Audio Asset Collection (Nihilex) | https://nihil-existentia.itch.io/free-audio-asset-collection | CC0 (segundo a página) | Inclui "Dark Ambient Soundscapes" |

Os links de música e da coleção Nihilex vieram de uma busca e precisam ser conferidos na página antes de usar.

## Pendências para os próximos planos

- Escolher o lobo (Plano 04) e testar a conversão do `.blend` para GLB.
- Lobisomem: decidir entre modelo CC-BY e o plano B em silhueta (Plano 09).
- Arte real da floresta (árvore, chão, céu do Poly Haven) entra no Plano 08.
