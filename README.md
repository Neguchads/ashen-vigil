# Ashen Vigil

RPG de fantasia sombria em primeira pessoa, com coop para até 4 amigos. Você acorda sem memória num lugar escuro, com uma carta que diz que alguém te observa; cada morte te devolve ao ponto de partida, e cada escolha muda o que vem depois.

Projeto de portfólio, em desenvolvimento. A história, os pilares e a arquitetura estão na [bíblia do projeto](docs/BIBLIA.md).

![Quarto iluminado pelo luar](docs/playtests/img/quarto-luar.png)

## O que já dá para jogar

A cena do despertar, com formas provisórias e alguns modelos CC0:

- acordar no quarto escuro, iluminado só pelo luar da janela;
- pegar a vela, que tremula e queima até acabar;
- ler a carta: *"Estamos te vendo. Estamos te observando. Tome cuidado com suas ações."*;
- sair pela porta e andar pela floresta enevoada.
- encontrar a adaga sobre uma pedra em frente à porta e equipá-la com **E**;
- carregar uma arma adicional pelo mod de exemplo, com modelo e atributos próprios.

- atacar com a adaga, bloquear e esquivar, com vida e stamina;
- enfrentar um lobo hostil e encontrar outro caído e ferido, distante na trilha;
- poupar o lobo ferido ou matá-lo; a escolha vale para a sessão atual;
- conversar com um viajante animado de armadura;
- pausar e ajustar gráficos, mouse, campo de visão e volume;
- após morrer, escolher **Despertar novamente** para reiniciar a cena.

Assets baixados e modelos integrados: [ASSETS](docs/ASSETS.md).

| Controle | Ação |
|---|---|
| WASD | andar |
| Mouse | olhar |
| Shift | correr |
| E | pegar, ler, fechar a carta |
| Mouse esquerdo | atacar com a arma equipada |
| Mouse direito | segurar para bloquear ataques pela frente |
| Espaço | esquivar na direção do movimento; parado, recuar |
| F | apagar ou reacender a vela enquanto houver combustível |
| Esc | fechar a leitura; fora dela, abrir/fechar pausa e configurações |

Clique na janela do jogo para capturar o mouse novamente. No menu, use
**Salvar configurações** para manter as preferências na próxima execução.

## Tecnologias e por quê

| Tecnologia | Por quê |
|---|---|
| Godot 4.7 (MIT) | Gratuito e open source; iluminação global, névoa volumétrica e áudio 3D prontos |
| GDScript tipado | Linguagem nativa do Godot, parecida com Python; a tipagem pega erro antes de rodar |
| GdUnit4 (MIT) | Testes automáticos que rodam sem abrir o editor |
| gdtoolkit (MIT) | Formatação e lint do GDScript |

As decisões técnicas, com o porquê de cada uma, estão em [DECISIONS.md](docs/DECISIONS.md).

## Como rodar

Pré-requisitos: [Godot 4.7.2](https://godotengine.org/download/windows/), Python 3.12 e PowerShell 7.

```powershell
# Ferramentas de lint (uma vez)
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt

# Defina onde está o Godot, se não for o caminho padrão do script
$env:GODOT_BIN = "C:\caminho\Godot_v4.7.2-stable_win64_console.exe"

# Formatação, lint, varredura de segredos e testes
pwsh -File scripts/check.ps1

# Jogar
& $env:GODOT_BIN --path game

# Medir fps (deixe a janela do jogo em primeiro plano)
& $env:GODOT_BIN --path game --resolution 1920x1080 --always-on-top -- --benchmark
```

## Estado atual

Para gerar e instalar a arma de exemplo, veja [MODDING](docs/MODDING.md).
O empacotamento usa o suporte nativo do Godot, sem dependências adicionais.

Veja o [ROADMAP](ROADMAP.md). Para mudar qualquer parte do jogo sem caçar arquivo, veja [COMO-EDITAR](docs/COMO-EDITAR.md).
