# Interface RPG — geração no modo Edit

Leia os arquivos `.luau` desta pasta e cole **o conteúdo inteiro** na Command Bar do Roblox Studio, fora do Play. Eles são independentes: não precisam de módulos geradores no jogo, plugins, `loadstring` nem acesso à internet.

Para instalar a versão nova, execute [00_All.luau](00_All.luau) uma vez em cada place. Depois salve o place. O Rojo continua sincronizando a lógica em `Common`, mas os objetos de interface ficam no Studio para você editar.

Os scripts individuais abaixo geram apenas a tela indicada. Ao executar novamente, a versão anterior é movida para `ServerStorage.RPGUIBackups`, com data e hora, antes de instalar a nova. Não execute `00_All` a cada Play: ele serve para instalar ou substituir o conjunto visual.

| Gerador | Destino no Studio |
| --- | --- |
| [01_Templates](01_Templates.luau) | `ReplicatedStorage.RPGUITemplates` |
| [02_Loading](02_Loading.luau) | `StarterGui.LoadingScreen` |
| [03_HUD](03_HUD.luau) | `StarterGui.HUD` |
| [04_Navigation](04_Navigation.luau) | `StarterGui.Buttons` |
| [05_Combat](05_Combat.luau) | `StarterGui.Attack` |
| [06_Inventory](06_Inventory.luau) | `StarterGui.Inventory` |
| [07_Skills](07_Skills.luau) | `StarterGui.SkillSelector` |
| [08_Zones](08_Zones.luau) | `StarterGui.ZoneSelector` |
| [09_Raids](09_Raids.luau) | `StarterGui.RaidsGUI` |
| [10_Players](10_Players.luau) | `StarterGui.Playerlist` |
| [11_Party](11_Party.luau) | `StarterGui.Partylist` |
| [12_Dialogue](12_Dialogue.luau) | `StarterGui.Dialogue` |
| [13_Shop](13_Shop.luau) | `StarterGui.Shop` |
| [14_Journal](14_Journal.luau) | `StarterGui.Journal` |
| [15_Notifications](15_Notifications.luau) | `StarterGui.Notifications` |
| [16_Tutorial](16_Tutorial.luau) | `StarterGui.Tutorial` |
| [17_StylePreview](17_StylePreview.luau) | `StarterGui.UIStylePreview` — referência visual |
| [18_Admin](18_Admin.luau) | `StarterGui.Main` — ferramentas do desenvolvedor |

## Editar sem perder alterações

- Edite cores, textos, fontes, tamanhos e posições diretamente nos objetos. Preserve os nomes e a hierarquia, pois a lógica encontra os controles por esses caminhos.
- Para ver uma janela no modo Edit, marque o `Visible` do seu frame principal. A inicialização fecha as janelas no Play, sem reconstruí-las. Loading e tutorial ficam desativados no Edit para não cobrir as outras telas.
- Edite os cards em `ReplicatedStorage.RPGUITemplates`. A lógica clona esses modelos para exibir itens, skills, diálogos, notificações e jogadores. Os clones recebem os dados atuais; os templates originais não são apagados nem recriados no Play.
- Position, Size e as propriedades das grades salvas no Studio valem em todos os dispositivos. O runtime ignora os antigos atributos Wide/Narrow, Breakpoint, CellMinWidth/CellHeight e NormalHeight/StorageHeight; abrir o storage nao redimensiona a mochila.
- Os objetos salvos em Studio não estão mapeados como arquivos Rojo. Salve o `.rbxl`/place para preservar suas edições. Um `rojo build` isolado contém a lógica, mas não inclui os objetos que você ainda não exportou do Studio.
- Para restaurar uma versão, mova os objetos do backup para o serviço indicado no atributo `OriginalService`, removendo antes a versão que você está substituindo.

## Inventário

Janela limitada a **740 px** de largura. Em `Inventory.Main.Body.Content`, `Hero` contém o personagem 3D, os slots ao redor e os stats abaixo; `Items` contém busca, cards, capacidade, armazenamento e ações. O layout mobile tambem fica sob seu controle no Studio, usando Scale e constraints. As abas HERO/ITEMS so alternam a visibilidade ao clicar, caso voce as deixe visiveis; nao existe mais troca automatica por resolucao.

O preview carrega a aparencia do usuario e guarda o modelo em cache enquanto a UI existir. Nao clona o personagem do mapa: adiciona somente a espada de Resources.Weapons, respeita vanity e toca o idle da arma equipada. Fechar e reabrir preserva o modelo. A camera mostra o avatar de frente com enquadramento mais proximo. Os stats continuam usando o calculo do jogo.

Passe o mouse por itens da mochila, armazenamento ou slots para ver nome, raridade, requisito, descrição, stats e valor. No mobile, toque no item para abrir os detalhes e ações, inclusive para materiais. O tooltip não depende de clique no desktop e fica limitado à área da tela.

## Manutenção e verificação

O estilo segue `Info/Read Me.txt` e `Info/UITheme.txt`: grafite, bordas escuras de 3 px, texto branco com contorno, botões coloridos com gradiente e cards de raridade. [17_StylePreview](17_StylePreview.luau) reúne os componentes como referência de novas telas.

As fontes dos geradores ficam em `tools/ui-source`. O tema central está em `Common/src/Shared/UI/Theme.luau`. Para atualizar os scripts standalone após mudar essas fontes:

```powershell
python tools/build_ui_generators.py
```

Verificação automatizada com o CLI oficial do Luau:

```powershell
python tools/verify_ui.py --luau CAMINHO/luau.exe
```

Os testes usam um mock de objetos/eventos e dados para checar geração, backups, hierarquia e cliques. Eles **não renderizam o motor Roblox**. No Studio, confira desktop, celular horizontal e vertical, respawn, troca de arma/aparência, tooltip perto das bordas e armazenamento com muitos itens.

A interface usa os serviços de gameplay existentes. Crafting e ofertas de skills inexistentes continuam indisponíveis; o seletor de habilidades segue os requisitos de nível atuais. O teleporte de raids depende da configuração do place de destino.

### Scale e TextScaled

Todos os geradores convertem as medidas de referencia para Scale antes de salvar as instancias, inclusive os atributos responsivos, grades e espacamentos. TextScaled fica ativo em todos os textos. Os offsets no codigo de construcao sao medidas do desenho de referencia; nao permanecem nas propriedades salvas. A conversao usa uma referencia fixa, sem depender do tamanho da janela do Studio. Bordas e limites de tamanho continuam sendo propriedades numericas do Roblox. Rode novamente o gerador em Edit mode para aplicar ao place e salve.

## Loading, player list e player card

Rode separadamente `02_Loading.luau`, `10_Players.luau` e `19_PlayerCard.luau` no Edit mode e salve. Os dois ultimos sao necessarios para a nova lista e seu card. Nao precisa regerar o inventario. O loading usa tipografia limpa, fundo azul profundo e detalhes em dourado discreto; BackgroundArt pode receber uma imagem sua no Studio.

A lista fica no topo direito, ordenada por nivel decrescente com o jogador local sempre primeiro e azul. Outros jogadores no limite de nivel ficam dourados, e os demais brancos. Tab alterna a lista. Ajuste no Studio sua posicao em relacao ao menu que voce personalizou. O card mostra avatar, equipamento, stats, ouro, kills, deaths, tempo total e tempo da sessao.

Os ImageLabels Rank ja existem. Preencha os IDs em `Common/src/Shared/UI/RankIcons.luau` quando criar os icones e atribua Rank ao Player (D, C, B, A, S, SS ou SSS). Nenhum rank e calculado automaticamente por enquanto.

O seletor de zonas agora abre detalhes de mobs, atributos, recompensas e drops antes de entrar. Para atualizar somente essa tela, execute `08_Zones.luau` em Edit e salve. Os templates usados pelo seletor ficam dentro de `StarterGui.ZoneSelector.Templates`; n?o ? necess?rio executar o gerador geral.
