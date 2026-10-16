# Mods de armas

O jogo base carrega de `game/core/mod.json`. As armas são Resources `.tres` com
nome, descrição, dano, custo de stamina, alcance e cena do modelo. O registro
resolve cada arma pelo ID, como `core:rusty_dagger`.

Hoje é possível adicionar armas e substituir os dados de uma arma existente.
As armas novas aparecem sobre pedras ao lado da adaga, logo à frente da porta.
Pressione **E** para equipar; a arma anterior é trocada. Combate e inventário
ficam para as próximas etapas.

## Gerar o exemplo

Na raiz do projeto, em PowerShell:

```powershell
pwsh -File scripts/build_mod.ps1 -Mod example_weapon
```

Saída: `build/mods/example_weapon/mod.json` e `example_weapon.pck`.
Para instalar no perfil normal do jogo:

```powershell
pwsh -File scripts/build_mod.ps1 -Mod example_weapon -Install
```

A instalação copia esses dois arquivos para
`%APPDATA%\Godot\app_userdata\Ashen Vigil\mods\example_weapon`.
Reinicie o jogo para carregar a alteração. Para desativar o mod, mova essa pasta
para fora de `mods`, com o jogo fechado.

## Criar uma arma

Copie `mods/example_weapon` para `mods/meu_mod`. Troque o ID do manifesto,
o prefixo dos caminhos e o ID da arma. O nome da pasta deve corresponder ao ID
do manifesto; os dois usam apenas letras minúsculas, números e `_`.
`core` é reservado ao jogo base.

```text
mods/meu_mod/
  mod.json
  content/
    minha_arma.tres
    modelo.tscn
```

Exemplo de manifesto:

```json
{
  "id": "meu_mod",
  "name": "Minha arma",
  "version": "1.0.0",
  "game_version": ">=0.1.0",
  "load_after": ["core"],
  "content": ["res://mods/meu_mod/minha_arma.tres"]
}
```

- `id`: nome técnico do mod, igual ao nome da pasta.
- `name`: nome legível.
- `version`: versão do mod, no formato `X.Y.Z`.
- `game_version`: versão exata ou mínima do jogo; são aceitos `X.Y.Z` e `>=X.Y.Z`.
- `load_after`: dependências que precisam carregar antes; opcional.
- `content`: definições que entram no registro; opcional. Modelos e materiais
  referenciados por elas ficam no pacote, sem entrar nessa lista.

Os arquivos de `content/` são montados em `res://mods/meu_mod/`.
Referências internas devem usar esse caminho final. A raiz da cena do modelo
deve ser `Node3D`; use o modelo do exemplo como referência de escala e orientação.
O empacotador atual atende `.tres`, `.tscn` e recursos de texto que não exigem
importação. Modelos GLB, texturas e áudio importados ainda não foram validados.

## Substituições e erros

O ID de conteúdo tem formato `<mod>:<nome>`, por exemplo `meu_mod:minha_arma`.
Para substituir a adaga, use `core:rusty_dagger` no `.tres` do mod. O ponto da
adaga usará a nova definição; outra cópia não aparece na área de demonstração.

`core` carrega primeiro. Dependências vêm antes dos dependentes; empates seguem
ordem alfabética. Para garantir que uma substituição vença outra, declare
`load_after`. O último registro de um mesmo ID vence.

JSON inválido, versão incompatível, manifesto ou pacote ausente, dependência
ausente e ciclos desativam o mod com motivo no relatório do carregador e no log.
Definições inexistentes ou de tipo incorreto são ignoradas com aviso; os demais
conteúdos continuam. O menu de mods ainda não foi implementado.

## Confiança nos mods

Um mod pode conter scripts, e o Godot não isola esses scripts. Instale só mods
de quem você confia. A lista `content` limita o registro, mas não transforma
pacotes `.pck` em arquivos seguros.

O mecanismo usa o [suporte nativo a pacotes do Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_pcks.html).
