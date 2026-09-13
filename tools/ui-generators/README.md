# Geradores da interface

Cole o conteúdo completo de um arquivo `.luau` na Command Bar do Roblox Studio com o Play parado. Cada gerador é independente e guarda a versão substituída em `ServerStorage.RPGUIBackups`.

Não execute `00_All` em um place que já recebeu ajustes manuais. Ele é somente a base completa para um place novo. Para atualizar uma parte, execute apenas o gerador incremental correspondente.

## Atualização desta entrega

Execute, nesta ordem:

1. `06_Inventory.luau`
2. `19_PlayerCard.luau`
3. `29_FeedbackTemplates.luau`

Isso substitui somente `StarterGui.Inventory`, `StarterGui.PlayerCard` e `ReplicatedStorage.RPGUITemplates.FeedbackTemplates`. A PlayerList e os demais templates não são alterados.

O Inventory foi reconstruído a partir do dump atual do Studio. Inventory e PlayerCard exibem valor total, progresso ganho por poções, limite e quantidade restante. O PlayerCard usa um avatar novo criado pela descrição do usuário, nunca uma cópia do personagem vivo, equipa a aparência da arma e toca o idle adequado.

`29_FeedbackTemplates` instala os efeitos de uso de skill, passiva, buff e debuff. A lógica apenas clona e anima esses objetos; posições, tamanhos, cores, camadas e demais propriedades visuais permanecem editáveis no Studio.

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
| `11_Party.luau` | `StarterGui.Partylist` |
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
