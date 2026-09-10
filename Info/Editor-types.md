# Tipos no VS Code

Abra a pasta raiz `Bootleg Sim`. `.vscode/settings.json` configura o Luau LSP para Roblox e gera `sourcemap.json` a partir de `editor.project.json`, que referencia o projeto de Lobbies. Isso mant?m os caminhos relativos corretos para `Common` e permite resolver os imports por `ReplicatedStorage`. O mapa ? gerado e ignorado pelo Git.

O caminho `luau-lsp.sourcemap.rojoPath` aponta para o Rojo 7.7.0 j? instalado nesta m?quina, pois o shim do Aftman falhou. Em outra m?quina, ajuste esse caminho para um execut?vel Rojo funcional. Para trabalhar com o contexto espec?fico de Raids, abra a pasta `Raids`, que j? possui sua pr?pria configura??o.

Depois de aplicar a configura??o, execute `Developer: Reload Window` na paleta do VS Code.

## Padr?o dos m?dulos

- `Types.PlayerData`: snapshot com valores simples, por exemplo `Level` num?rico.
- `Types.PlayerDataValue`: c?lulas reativas do DataServiceTyped, por exemplo `Level()` e `Level(12)`.
- Equipamentos e po??es: a tabela ? constru?da junto com seus m?todos e validada em `local TypedItem: Types.Equipment = Item` (ou `Types.Consumable`) antes do retorno. Isso permite exigir os m?todos sem marcar a tabela inicial incompleta como inv?lida. `Kind` usa o tipo literal correspondente.
- Materiais: `Types.Material`, sem os campos e m?todos de consumo exclusivos das po??es.
- Mobs: `Types.MobInfo`, moedas num?ricas e HP/MaxHP opcionais, pois s?o dados de runtime. Critical Power ? opcional e o combate usa zero quando ausente.

Valida??o realizada com Luau LSP e as defini??es Roblox: todos os m?dulos de ItemsData e MobsData, Types e suas depend?ncias sem diagn?sticos. O harness `tools/verify_equipment.py` tamb?m passou. Isso n?o representa uma auditoria de tipos de todos os scripts do jogo.

Refer?ncia: https://github.com/JohnnyMorganz/luau-lsp/blob/main/README.md
