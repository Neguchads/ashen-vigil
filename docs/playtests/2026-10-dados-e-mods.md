# Validação: dados e mods (2026-10-16)

## Entrega

Adaga coletável sobre uma pedra à frente da porta da casa, criada pelo ID
`core:rusty_dagger`. **E** equipa a arma e mostra seu modelo na mão; a vela
continua na outra mão. Outra coleta troca a arma anterior. O pickup fica
inativo e sem colisão após a coleta.

O mod `example_weapon` adiciona uma lâmina maior, com modelo e atributos próprios,
sem alterar código. Depois de instalado e de reiniciar o jogo, ela aparece
ao lado da adaga. Ambos ainda usam formas simples, sem arte final.

![Armas do jogo base e do mod na floresta](img/dados-e-mods.png)

![Adaga equipada junto da vela](img/adaga-equipada.png)

## Verificações executadas

- `pwsh -File scripts/check.ps1`: formatação, lint, varredura de segredos
  incluindo arquivos novos, importação e **76 testes em 16 suítes**, com zero
  erros, falhas, testes pulados ou nós órfãos. Eram 27 testes antes desta etapa.
- `pwsh -File scripts/build_mod.ps1 -Mod example_weapon -Install`: gerou
  `mod.json` e `example_weapon.pck` e copiou ambos para um perfil isolado dentro
  de `game/.godot/preview-profile`. O perfil pessoal não recebeu o exemplo.
- Inicialização com renderização real em Forward+, RTX 3060, 1280×720:
  carregou o pacote instalado, exibiu as duas armas, equipou a adaga e depois
  a arma do mod. O roteiro conferiu o ID e o dano da arma instalada e salvou
  as capturas acima. Nenhum erro no log dessa execução.
- Caminho de mod inválido (`..\escape`) foi rejeitado pelo empacotador.
- `git diff --check`: sem problemas de espaços em branco.
- Revisão independente do código: corrigidos cache de modelos externos,
  descarte de cena com raiz incompatível e tentativa de instanciar cena vazia.
  Cada problema ganhou teste observado falhando antes da correção e passando depois.

Os testes de integração exercitam o raio de interação e a coleta. Não houve
playtest humano de movimentação, ritmo ou ambientação nesta etapa.

## Ambiente de testes

`check.ps1` usa `game/.godot/check-profile` como perfil isolado, restaurando
`APPDATA` ao sair. Os logs são individuais por execução. A importação agora
falha também quando o Godot imprime erro mesmo retornando código zero.

A restrição de arquivos do ambiente de execução inicialmente causou
`Safe save failed` no editor. A importação e a verificação final foram
reexecutadas com permissões normais e terminaram sem esse erro.

## Como conferir no jogo

Na raiz do projeto, em PowerShell:

```powershell
& 'A:\AI\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --path game
```

Pegue a vela, leia a carta e saia pela porta. A adaga fica sobre uma pedra,
logo à frente. Aproxime-se, olhe para ela e pressione **E**. Para testar a arma
adicional no perfil normal, siga `docs/MODDING.md`.

## Limites e continuidade

Combate, inventário, menu de mods, executável exportado e pacotes com GLB,
texturas ou áudio importados não foram implementados ou validados nesta etapa.
Não houve benchmark novo de fps, teste em GTX 1060, commit, push, PR ou publicação.
Próxima etapa prevista: Plano 03, loop temporal.
