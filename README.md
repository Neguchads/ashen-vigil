# Ashen Vigil

RPG de fantasia sombria em primeira pessoa, com coop para até 4 amigos. Você acorda sem memória num lugar escuro, com uma carta que diz que alguém te observa; cada morte te devolve ao ponto de partida, e cada escolha muda o que vem depois.

Projeto de portfólio, em desenvolvimento. A história, os pilares e a arquitetura estão na [bíblia do projeto](docs/BIBLIA.md).

![Quarto iluminado pelo luar](docs/playtests/img/quarto-luar.png)

## O que já dá para jogar

A cena do despertar, em *greybox* (formas simples no lugar da arte final):

- acordar no quarto escuro, iluminado só pelo luar da janela;
- pegar a vela, que tremula e queima até acabar;
- ler a carta: *"Estamos te vendo. Estamos te observando. Tome cuidado com suas ações."*;
- sair pela porta e andar pela floresta enevoada.

| Controle | Ação |
|---|---|
| WASD | andar |
| Mouse | olhar |
| Shift | correr |
| E | pegar, ler, fechar a carta |
| Esc | fechar a carta ou soltar o mouse |

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

Veja o [ROADMAP](ROADMAP.md). Para mudar qualquer parte do jogo sem caçar arquivo, veja [COMO-EDITAR](docs/COMO-EDITAR.md).
