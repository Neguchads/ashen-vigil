# Decisões técnicas

Cada decisão registra o que foi escolhido, o porquê e a alternativa descartada.

## 2026-10-16: combate e configurações com os recursos do motor

- **Escolha:** `CombatVitals` para vida/stamina, `CombatController` para ataque, bloqueio e esquiva, e `EnemyDef` para atributos/modelo por ID. A consulta física do golpe respeita paredes e alcance; o acerto só ocorre uma vez após a preparação.
- **Por quê:** entrega o combate pedido sem adicionar framework, addon ou um arquivo para cada estado. A cena continua trocável pelos dados do registro.
- **Menu:** controles nativos, pausa real do mundo e preferências em `user://settings.cfg`. Pausar preserva a recuperação do ataque; apenas libera o bloqueio para evitar uma defesa presa ao voltar.
- **Animações:** clipes dos modelos para descanso/caminhada, transformações para golpe da arma, avanço/queda do lobo e balanço da arma. Movimento reduzido desliga o balanço cosmético, mantendo a indicação do ataque.
- **Assets:** cinco pacotes CC0, com fontes e hashes. A biblioteca fica fora de `game/`; somente os modelos selecionados entram no carregamento. A estética desses modelos é provisória.
- **Escopo:** antecipar a base de combate e o lobo ferido conforme o pedido atual. Reinício manual após morrer; diário, prazo e consequências narrativas persistentes continuam pendentes.

## 2026-10-16: primeira fatia de conteúdo e mods

- **Escolha:** implementar as definições `ContentDef`, `ItemDef` e `WeaponDef`, registro por ID, manifesto, ordem de dependências e pacotes nativos `.pck`. A adaga nasce de um `ContentSpawner`; as armas de mods aparecem ao lado dela na área de demonstração.
- **Por quê:** entrega uma arma nova no jogo sem editar o código, usando o motor e as ferramentas já instaladas. Combate, inventário e outras classes de conteúdo entram quando forem necessários.
- **Modelos:** a mesma cena indicada na definição aparece na pedra e na mão. A vela continua disponível na outra mão.
- **Cache:** o carregamento usa `CACHE_MODE_REPLACE_DEEP`; testes mostraram que substituir apenas a definição mantém modelos externos antigos no cache.
- **Verificação:** `check.ps1` usa um perfil local isolado em `game/.godot/check-profile`, sem executar os mods instalados no perfil pessoal. Arte final, menu de mods, executável exportado e pacotes com assets importados continuam pendentes.

## 2026-10-15: Godot 4 no PC, não navegador

- **Escolha:** Godot 4.7 (MIT), com executável para Windows.
- **Por quê:** iluminação global, névoa volumétrica e áudio 3D prontos, que é onde nasce a imersão. É gratuito e open source.
- **Descartado:** Three.js no navegador. Rodaria por um link, mas teria um teto de imersão menor e mais trabalho manual.

## 2026-10-15: coop com autoridade dividida

- **Escolha:** cada jogador decide o próprio movimento e a própria vida. O host decide inimigos, loot e o estado do mundo.
- **Por quê:** não há atraso ao andar, e não é preciso prever e corrigir o movimento de cada cliente. Entre amigos, trapaça não importa.
- **Descartado:** autoridade total do host (complexidade de jogo competitivo) e um mundo persistente com servidor (custo mensal e muito mais trabalho).

## 2026-10-15: coop desde o início

- **Escolha:** a rede faz parte da primeira versão. Jogar sozinho é hospedar sem clientes.
- **Por quê:** adicionar multiplayer num jogo pronto costuma obrigar a reescrever quase tudo.

## 2026-10-15: detalhe de PS3 com iluminação moderna

- **Escolha:** modelos com detalhe da era PS3 e luz moderna do Godot 4 (SDFGI, névoa volumétrica), com um preset visual por área.
- **Por quê:** imersão vem de luz, som e coerência visual. O alvo de 60 fps numa GTX 1060 mantém o jogo leve.
- **Descartado:** estética retrô de PS1/PS2. O Gustavo achou que ficaria feio.

## 2026-10-15: conteúdo por ID e jogo base como "mod zero"

- **Escolha:** todo conteúdo é um `Resource` com ID (`core:longsword`). O jogo base é o mod `core` e carrega pelo mesmo caminho que os mods.
- **Por quê:** qualquer parte fica editável sem programar. O sistema de mods é testado o tempo todo pelo próprio jogo. A mesma base serve ao futuro modo criativo.

## 2026-10-15: sandbox depois do RPG

- **Escolha:** modo criativo estilo Garry's Mod na fase 2 e scripts dentro do jogo estilo Roblox na fase 3.
- **Por quê:** os dois são plataformas do tamanho do RPG ou maiores. Juntar tudo de início é o jeito mais comum de um projeto solo nunca terminar.

## 2026-10-15: retorno pela morte no lugar das fogueiras

- **Escolha:** loop estilo Re:Zero. A morte, o fim do prazo ou um evento fatal devolvem o jogador à âncora. A âncora só avança ao concluir uma parte principal.
- **Por quê:** a morte vira parte da história e dispensa tutorial. A fogueira do Souls faria a mesma coisa (resetar inimigos) de forma redundante.
- **Persistência:** só o diário de pistas sobrevive ao loop. É fiel ao Re:Zero e ajuda quem esquece uma pista.

## 2026-10-15: loop em coop com espectro

- **Escolha:** quem morre vira espectro, e o grupo inteiro volta quando o último vivo morre ou quando o prazo acaba.
- **Por quê:** mantém a tensão sem punir 3 pessoas pelo erro de 1.
- **Descartado:** reiniciar todos a cada morte (frustrante em grupo de 4) e história só solo.

## 2026-10-15: prazo mostrado no mundo, não na tela

- **Escolha:** a lua se move, o céu muda e sinos tocam. Sem cronômetro na tela.
- **Por quê:** um cronômetro quebra a imersão.

## 2026-10-15: fatia vertical é o Capítulo 1

- **Escolha:** do despertar até passar pela muralha. Castelo, masmorra e chefe ficam para o capítulo 2.
- **Por quê:** o loop, o diálogo e a ambientação cinematográfica já são trabalho de sobra. Uma fatia menor e polida demonstra mais que uma grande e crua.

## 2026-10-15: Dialogue Manager para os diálogos

- **Escolha:** addon Dialogue Manager (MIT), com diálogos escritos em texto e condições ligadas ao diário.
- **Por quê:** é pronto, gratuito, editável sem programar e funciona como mod.
- **Descartado:** escrever um sistema de diálogo do zero.

## 2026-10-15: escolhas definitivas só ao fechar uma parte

- **Escolha:** dentro do loop, a escolha é provisória. Ao concluir uma parte principal, as escolhas daquele loop viram definitivas, e as consequências podem aparecer muito depois (efeito borboleta).
- **Por quê:** resolve o conflito entre o loop, que desfaz tudo, e as escolhas, que precisam valer. Voltar no tempo passa a servir também para mudar o resultado.
- **Controle de custo:** galhos que se reencontram, muitas consequências pequenas e final calculado por poucas escolhas-chave, como em Witcher 3 e Fallout 4.

## 2026-10-15: identidade própria por capítulo

- **Escolha:** cada capítulo tem tom, preset visual e músicas próprios, definidos num `ChapterDef`. A régua de tom fica em `docs/historia/mundo.md`.
- **Por quê:** a mistura de influências (Tolkien, HP, Souls, Fable, Castlevania) só funciona se cada cenário usar a que combina com ele, e não todas ao mesmo tempo.

## 2026-10-15: fragmentos de memória como sistema

- **Escolha:** cada flashback vira um `FragmentDef` no diário, que sobrevive ao loop e destrava escolhas e falas, igual às pistas.
- **Por quê:** a história do protagonista (memória apagada que nunca se completa) precisa de um mecanismo de jogo. Reaproveitar o diário evita um sistema novo.

## 2026-10-16: testes do Godot sem modo debug e com tempo limite

- **Escolha:** o `check.ps1` roda o GdUnit4 sem a flag `-d` e mata o processo depois de 5 minutos.
- **Por quê:** com `-d`, um erro de parse abre o depurador interativo do Godot, que fica esperando um comando para sempre. Num teste isso gerou 1,4 GB de log. Sem `-d`, o erro vira falha normal.

## 2026-10-16: benchmark só com a janela em primeiro plano

- **Escolha:** medir fps com `--always-on-top` e registrar também o tempo de GPU por quadro.
- **Por quê:** o Windows 11 desacelera processos com janela em segundo plano; os números caíam para 20 a 47 fps sem relação com a cena. O tempo de GPU (5,5 ms) mostra o custo real da cena, independente disso.

## 2026-10-16: jogável desde o começo, em greybox

- **Escolha:** cada plano termina com algo novo para jogar. A primeira cena (acordar, vela, carta, floresta) é feita em greybox, com formas simples, e a arte real entra depois trocando propriedades.
- **Por quê:** o Gustavo quer ver o jogo crescer, não semanas só de base invisível. O greybox também revela cedo problemas de escala, ritmo e clima, quando ainda são baratos de corrigir.
- **Descartado:** um teste visual descartável antes da fundação. Ele seria jogado fora; o greybox vira o próprio jogo.

## 2026-10-15: conexão via VPN gratuita no MVP

- **Escolha:** IP e porta, com guia para Tailscale ou Radmin VPN.
- **Por quê:** custo zero e nenhuma infraestrutura. Um relay que atravessa o roteador fica para a fase 2.
