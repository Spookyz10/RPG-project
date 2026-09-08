# RPG

`Common/src` contém o código compartilhado por Lobbies e Raids. Edite ali para atualizar os dois places. `Common/Packages`, `Common/wally.toml` e `Common/wally.lock` centralizam as dependências; execute `wally install` dentro de `Common` para atualizá-las.

Os dois `default.project.json` mantêm os caminhos existentes no Roblox:

| Pasta em Common/src | Destino no Roblox |
| --- | --- |
| Shared | ReplicatedStorage.Shared |
| Modules | ServerStorage.Modules |
| Server | ServerScriptService.Server |
| First | ReplicatedFirst.First |
| Client | StarterPlayer.StarterPlayerScripts.Client |

As pastas `Lobbies/src` e `Raids/src` ficam reservadas para código específico de cada place. Cada uma tem as mesmas cinco subpastas, mapeadas para uma pasta `Place` no respectivo serviço (por exemplo, `Raids/src/Server` vai para `ServerScriptService.Place` apenas em Raids). Elas não sobrescrevem os scripts de Common. Quando uma lógica precisar divergir, retire sua versão compartilhada e coloque as versões específicas nas pastas de cada place, ajustando as referências necessárias.

Por enquanto, todo o código existente continua compartilhado, inclusive o comportamento de lobby que Raids recebeu no clone.

Na raiz do repositório, use:

```powershell
rojo serve Lobbies/default.project.json
# ou
rojo serve Raids/default.project.json
```

Também é possível executar `rojo serve` dentro da pasta do place desejado.

## Interface editável

A interface é gerada **no modo Edit do Studio**, com scripts separados em [tools/ui-generators](tools/ui-generators/README.md). Execute `00_All.luau` para instalar o conjunto, salve o place e edite os objetos em `StarterGui` e `ReplicatedStorage.RPGUITemplates`. A lógica em `Common/src/Shared/UI` conecta esses objetos no Play; não recria as telas nem sobrescreve o visual salvo.
