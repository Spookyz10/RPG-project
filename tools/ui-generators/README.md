# Geradores da interface

Cole o conteúdo completo de um arquivo `.luau` na Command Bar do Roblox Studio com o Play parado. Cada gerador é independente e guarda a versão substituída em `ServerStorage.RPGUIBackups`.

Não execute `00_All` em um place que já recebeu ajustes manuais. Ele é somente a base completa para um place novo. Para atualizar uma parte, execute apenas o gerador incremental correspondente.

## Atualização desta entrega

Execute, nesta ordem:

1. `12_Dialogue.luau`
2. `32_JournalIndicators.luau`
3. `33_CraftingTooltip.luau`
4. `34_NPCInteractionTemplate.luau`
5. `35_CraftingRecipeTemplate.luau`

`12_Dialogue` substitui somente `StarterGui.Dialogue` pela caixa compacta. `32_JournalIndicators` preserva `StarterGui.Buttons` e apenas completa o atalho Journal e os badges de quest. `33_CraftingTooltip` preserva a tela de Crafting e clona nela o tooltip visual do Inventory. `34_NPCInteractionTemplate` instala o visual da interação customizada dos NPCs. `35_CraftingRecipeTemplate` troca somente `StarterGui.Crafting.RecipeTemplate`.

## Índice

| Arquivo | Destino |
| --- | --- |
| `00_All.luau` | base completa para place novo |
| `01_Templates.luau` | `ReplicatedStorage.RPGUITemplates` completo |
| `02_Loading.luau` | `StarterGui.LoadingScreen` |
| `03_HUD.luau` | `StarterGui.HUD` |
| `04_Navigation.luau` | `StarterGui.Buttons` |
| `05_Combat.luau` | `StarterGui.Attack` |
| `06_Inventory.luau` | `StarterGui.Inventory` |
| `07_Skills.luau` | `StarterGui.SkillSelector` |
| `08_Zones.luau` | `StarterGui.ZoneSelector` |
| `09_Raids.luau` | `StarterGui.RaidsGUI` |
| `10_Players.luau` | `StarterGui.Playerlist` |
| `12_Dialogue.luau` | `StarterGui.Dialogue` |
| `13_Shop.luau` | `StarterGui.Shop` |
| `14_Journal.luau` | `StarterGui.Journal` |
| `15_Notifications.luau` | `StarterGui.Notifications` |
| `16_Tutorial.luau` | `StarterGui.Tutorial` |
| `17_StylePreview.luau` | `StarterGui.UIStylePreview` |
| `18_Admin.luau` | `StarterGui.Main` |
| `19_PlayerCard.luau` | `StarterGui.PlayerCard` |
| `20_Crafting.luau` | `StarterGui.Crafting` |
| `21_MobOverhead.luau` | somente o template `MobOverhead` |
| `22_Leaderboards.luau` | `StarterGui.Leaderboards` |
| `23_ToastTemplate.luau` | somente o template `ToastTemplate` |
| `24_LootRewards.luau` | `StarterGui.LootRewards` |
| `25_ZoneTransition.luau` | `StarterGui.ZoneTransition` |
| `26_DeathScreen.luau` | `StarterGui.DeathScreen` |
| `27_DumpCurrentUI.luau` | captura segura; não altera a UI |
| `29_FeedbackTemplates.luau` | somente `FeedbackTemplates` |
| `30_LevelUpFeedback.luau` | somente o template `LevelUpFeedback` |
| `31_PartyHUD.luau` | somente `StarterGui.HUD.Main.PartyOverlay` |
| `32_JournalIndicators.luau` | somente atalho Journal e badges em `StarterGui.Buttons` |
| `33_CraftingTooltip.luau` | somente `StarterGui.Crafting.ItemTooltip` |
| `34_NPCInteractionTemplate.luau` | somente `ReplicatedStorage.RPGUITemplates.NPCInteractionTemplate` |
| `35_CraftingRecipeTemplate.luau` | somente `StarterGui.Crafting.RecipeTemplate` |
| `36_DailyRewards.luau` | `StarterGui.DailyRewards` |
| `37_ShopTemplate.luau` | somente `ReplicatedStorage.RPGUITemplates.ShopTemplate` |

## Shop de poções

Execute `37_ShopTemplate.luau` e depois `13_Shop.luau` na Command Bar, em Edit, e sincronize Common pelo Rojo. O Shopkeeper abre `Shop`, que vende apenas as cinco Small Potions: Health (35 Gold), Attack (60), Defense (60), Speed (180) e Critical (240). Os controles menos/mais permitem comprar de 1 a 25 poções empilháveis; o preço total é exibido antes de comprar. O servidor calcula o custo novamente, limita a quantidade e desconta somente as unidades que realmente couberem no inventário.

## Manutenção

As fontes ficam em `tools/ui-source`. Depois de alterá-las, regenere os arquivos standalone:

```powershell
python tools/build_ui_generators.py
```

O runtime pode atualizar texto, imagem, visibilidade, progresso e clones temporários. A geometria estática pertence aos objetos salvos no Studio. Preserve os nomes e a hierarquia usados pela lógica.

Os objetos gerados não fazem parte do build Rojo enquanto não forem exportados. Salve o place após executar os scripts. Para restaurar uma versão, use o backup cujo atributo `OriginalService` indica o serviço original.

Para verificação automatizada, informe um executável oficial do Luau:

```powershell
python tools/verify_ui.py --luau CAMINHO/luau.exe
```

O teste automatizado verifica contratos e hierarquia, mas não renderiza a interface. No Studio, confira desktop e mobile, troca de aparência/arma, respawn, abertura repetida do PlayerCard e vários buffs ou passivas disparados em sequência.
# Daily rewards

Execute `36_DailyRewards.luau` inteiro na Command Bar em Edit e sincronize Common pelo Rojo. Cria `StarterGui.DailyRewards`, incluido tambem em `00_All.luau`. Para visualizar/editar o card no Studio, habilite temporariamente `Card.Visible`; mantenha-o falso antes de salvar para Play.

Entre no alcance de `Workspace.Touchies.Daily` (Part com nome exato `Daily`, como os outros Touchies). A entrada solicita claim uma vez; o servidor valida personagem vivo, proximidade, limite de pedidos e cooldown de 24 horas. Sucesso mostra ouro, XP e streak com animacao de entrada; fecha pelo botao ou depois de 8 segundos. Cooldown usa apenas a Notification/Toast existente. A UI nao altera posicoes ou tamanhos salvos; apenas o UIScale da animacao.

Verifique em Studio: primeiro claim, sair/reentrar durante cooldown, ficar parado no Touchie sem novos pedidos, respawn, e dois jogadores com cooldowns independentes. O gerador nao modifica os dados persistidos para forcar um teste.
