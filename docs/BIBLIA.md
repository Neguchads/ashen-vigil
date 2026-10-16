# Bíblia do projeto: Ashen Vigil

Documento de entrada do projeto. Resume tudo e aponta para o detalhe. Nome provisório.

Legenda: **[G]** é ideia do Gustavo. **[P]** é proposta do Claude ainda não aprovada.

## 1. O que é

RPG de fantasia em 3D, em primeira pessoa com opção de terceira, para jogar sozinho ou em coop com até 4 amigos.

Um homem acorda sem memória num lugar escuro, com uma carta que diz que alguém o observa. Cada morte o devolve ao ponto de partida. Cada escolha muda o que vem depois. Aos poucos, por fragmentos que nunca se completam, ele descobre quem foi.

Inspirações: Gothic, Skyrim, Dark Souls, Elden Ring, Fable, Castlevania, Tolkien, Harry Potter, Re:Zero, Witcher 3, Fallout 4 e Life is Strange. O mundo, os nomes e as línguas são próprios.

## 2. A história

**Sem spoiler.** O jogador acorda num quarto escuro, sem memória, sem classe e sem arma. Acha uma vela e uma carta: *"Estamos te vendo. Estamos te observando. Tome cuidado com suas ações."* Lá fora há uma floresta enevoada, risadas de criança e algo que caça à noite.

**Com spoiler** (detalhe em `historia/mundo.md`):

- O protagonista já foi o chefão final de outra linha do tempo. **[G]**
- Os amigos dele não conseguiram detê-lo. Então apagaram a memória dele e o mandaram, com magia de reversão do tempo, para uma linha alternativa. Agora o observam. **[G]**
- Ele sente fragmentos de realidades paralelas (cheiros, visões, sons) e nunca vai lembrar tudo. **[G]**
- As risadas misturam infância, pecados e as maldições da floresta. **[G]**
- A espada da runa pertencia a um bruxo de outra realidade e está ligada a alguém que ele conheceu. **[G]**
- A pergunta do jogo é "ele vai virar o chefão de novo?". As escolhas respondem. **[P]**

## 3. Pilares

Toda decisão de design precisa servir a pelo menos um pilar.

1. **Imersão.** O jogador sente que está lá: luz, som, névoa, silêncio e nenhum tutorial.
2. **Memória e tempo.** Morrer faz parte da história. O conhecimento é a arma principal.
3. **Escolhas que pesam.** O que você faz volta depois, às vezes muito depois.
4. **Juntos.** Coop com amigos sem atrapalhar a história.
5. **Feito para ser mexido.** Tudo é editável, e mods são cidadãos de primeira classe.

## 4. Mecânicas principais

| Mecânica | Resumo | Detalhe |
|---|---|---|
| Retorno pela morte | Morte, fim do prazo ou evento fatal devolvem o grupo à âncora | Spec, seção 3.1 |
| Relógio do mundo | O prazo aparece no céu, na lua e nos sinos, não num cronômetro | Spec, seção 3.3 |
| Diário | Pistas e fragmentos de memória; é o que sobrevive ao loop | Spec, seções 3.4 e 3.6 |
| Escolhas e efeito borboleta | Provisórias no loop, definitivas ao fechar uma parte, consequências atrasadas | Spec, seção 3.5 |
| Flashbacks | Cheiros, visões e sons de outras realidades, sempre incompletos | Spec, seção 3.6 |
| Combate souls-like | Stamina, esquiva, bloqueio; adaga, arco, espada e magia da runa | Spec, seção 5.3 |
| Sem classe | A forma de jogar nasce do que o jogador encontra | Spec, seção 2 |
| Coop | 1 a 4 jogadores; quem morre vira espectro; o grupo volta junto | Spec, seções 3.2 e 8 |
| Mods | O jogo base é o "mod zero"; mods adicionam ou substituem conteúdo por ID | Spec, seção 7 |
| Console | Gerar itens, pular para uma hora, forçar o loop; semente do modo criativo | Spec, seção 9.2 |

## 5. Mundo e tons

Cada capítulo tem essência própria **[G]**. Tons dos capítulos 2 em diante são proposta **[P]**.

| Capítulo | Tom | Influências |
|---|---|---|
| 1. O Despertar | Terror, suspense e drama | Gothic, Souls, Re:Zero |
| 2. A cidade além da muralha **[P]** | Aventura nostálgica | Fable, Skyrim, Gothic |
| 3. O castelo **[P]** | Gótico | Castlevania, Souls |
| 4. A torre arcana **[P]** | Mistério mágico | Harry Potter, Tolkien |
| 5. As ruínas antigas **[P]** | Épico melancólico | Elden Ring, Tolkien |

## 6. Tecnologias

Todas gratuitas. As versões foram conferidas em 2026-10-15.

| Tecnologia | Para quê | Por que esta |
|---|---|---|
| Godot 4.7.2 (MIT) | Motor do jogo | Gratuito e open source; iluminação global, névoa volumétrica e áudio 3D prontos |
| GDScript | Linguagem | Nativa do Godot, parecida com Python, fácil de ler |
| Terrain3D (MIT) | Terreno da floresta | O Godot não tem editor de terreno embutido |
| Dialogue Manager (MIT) | Diálogos com condições | Diálogos escritos em texto, editáveis e moddáveis |
| Rede de alto nível do Godot (ENet) | Coop | Embutida; sem servidor pago |
| `AudioStreamInteractive` | Música adaptativa | Recurso nativo; troca de música no compasso certo |
| GdUnit4 (MIT) | Testes automáticos | Roda sem abrir o editor |
| gdtoolkit (MIT) | Lint e formatação | Mantém o código padronizado |
| Git, GitHub e Git LFS | Versão do código e dos assets | LFS grátis até 10 GiB |
| Tailscale ou Radmin VPN | Conectar amigos | Grátis; dispensa abrir porta no roteador |
| Poly Haven, Mixamo, Fab, Sketchfab, Sonniss | Modelos, animações e sons | Gratuitos; licença conferida asset a asset em `CREDITS.md` |
| itch.io | Publicar o jogo | Gratuito, feito para jogos independentes |

## 7. Arquitetura

O jogo tem três camadas. Cada uma só conversa com a de baixo.

```
+------------------------ Jogo (cenas) ------------------------+
|  Player   Inimigos   Áreas   Interface   Cenas de cinema      |
|  usam componentes: Health, Stamina, Interactable, Resettable  |
+--------------------------------------------------------------+
                              |
+------------------- Sistemas (autoloads) ---------------------+
|  LoopManager  WorldClock  Journal  Choices  Net  SaveGame     |
|  Settings  DevConsole                                         |
+--------------------------------------------------------------+
                              |  procuram conteúdo por ID
+------------------------ Conteúdo (dados) --------------------+
|  ContentRegistry  <--  ModLoader  <--  core + mods (.pck)     |
|  ItemDef, WeaponDef, EnemyDef, ClueDef, FragmentDef,          |
|  ChoiceDef, EndingDef, PartDef, ChapterDef ... (.tres)        |
+--------------------------------------------------------------+
```

Ideias centrais:

- **Conteúdo é dado, não código.** Números, falas, escolhas e finais ficam em arquivos editáveis.
- **O jogo base é um mod.** O `core` carrega pelo mesmo caminho que qualquer mod.
- **Tudo que muda durante o loop é `Resettable`.** O reset é automático e testado.
- **Coop com autoridade dividida.** Cada jogador decide o próprio corpo; o host decide o mundo.
- **Jogar sozinho é hospedar sem ninguém.** Só existe um caminho de código.

Detalhe completo: `superpowers/specs/2026-10-15-ashen-vigil-design.md`.

## 8. Como construímos

- **Fatias médias:** cada etapa entrega algo inteiro e jogável.
- **Branch, PR e merge, nunca direto na `main`.** Antes do merge, `scripts/check.ps1` passa (lint, testes, rede, loop e mods), um revisor automático lê o diff e mudanças visuais são vistas rodando o jogo.
- **O visual e o som são aprovados pelo Gustavo.** Teste automático não julga clima.
- **Cada decisão técnica vai para `DECISIONS.md`,** com o porquê, para ser explicada em entrevista.
- **Cada asset vai para `CREDITS.md`,** com fonte e licença.

## 9. Roadmap

Resumo; o acompanhamento fica em `../ROADMAP.md`.

1. **Primeiro jogável:** acordar no quarto, vela, carta e floresta à noite, em greybox.
2. **Capítulo 1 completo,** crescendo jogável a cada etapa: dados e mods, loop, combate, coop, diálogo e escolhas, console, mundo com arte real, história e cinema, polimento.
3. **Versão 1.0:** Capítulo 1 publicado no itch.io (só com confirmação).
4. **Capítulo 2 e modo criativo** estilo Garry's Mod.
5. **Capítulos 3 a 5.**
6. **Scripts dentro do jogo** estilo Roblox, se as fases anteriores vingarem.

## 10. Mapa dos documentos

| Documento | O que tem |
|---|---|
| `BIBLIA.md` | Este resumo |
| `superpowers/specs/2026-10-15-ashen-vigil-design.md` | Especificação técnica completa |
| `historia/mundo.md` | Verdade oculta, influências e tons dos capítulos |
| `historia/capitulo-1.md` | Sequência, escolhas e revelações do Capítulo 1 |
| `historia/ideias.md` | Ideias guardadas para depois |
| `DECISIONS.md` | Decisões técnicas e o porquê |
| `../ROADMAP.md` | Feito, em andamento e planejado |
