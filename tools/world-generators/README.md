# World generators

## Portal billboards

Execute `03_PortalBillboards.luau` inteiro na Command Bar em Edit. Cria `Workspace.PortalSigns.Zones` (azul) e `Raids` (vermelho), com BillboardGui sobre uma Part invisivel. Mova os Models para posicionar as placas. Nao cria Touchies nem altera portais ou leaderboards. Ao reexecutar, preserva as posicoes dos dois Models e arquiva os anteriores em `ServerStorage.WorldGeneratorBackups`.

## Lobby

Com o Play parado, execute `00_Lobby.luau` inteiro na Command Bar do Roblox Studio em modo **Edit**. O gerador cria `Workspace.Maps.Lobby` no mesmo estilo low-poly da Grasslands, seleciona o mapa pronto e preserva uma versao anterior em `ServerStorage.WorldGeneratorBackups` quando for executado novamente.

O lobby v2 foi reconstruido com praca circular, fonte, jardins, bancos, loja aberta com toldo, blacksmith com forja e chamine (sem NPC), portais azul e vermelho com silhuetas distintas e pavilhao com bau de daily reward. Os telhados usam uma inclinacao calculada em comum para as duas aguas, empenas e cumeeira. Nao ha portao nem placa "Adventurers' Lobby".

`Workspace.Maps.Lobby.LobbySpawn` e um SpawnLocation real, neutro, habilitado e invisivel sobre a praca. Outros spawns ja existentes fora do lobby sao preservados e podem continuar participando da escolha de respawn do Roblox.

Os quatro modelos em `Workspace.Maps.Lobby.Landmarks.Leaderboards` sao apenas construcoes: `Gold` tem colunas, moedas e coroa; `Kills` tem presas, escudo e espadas; `Donations` tem cristais e louros; `PlayTime` tem um relogio ornamental. Cada modelo tem uma Part `DisplaySurface` de 20 x 21 studs; use a face **Front** ao configurar sua UI manualmente. Ficam dentro do mapa, sem substituir `Workspace.Leaderboards` nem disparar a vinculacao automatica por `IMG` do cliente existente. O gerador nao cria/edita SurfaceGuis, Adornees ou logica de UI. O relogio e estatico.

Portais e daily reward sao visuais, sem Touchies, prompts, scripts, destinos ou entrega de recompensas. Conecte as interacoes manualmente. Reexecutar arquiva o lobby anterior inteiro (incluindo seu spawn e eventuais edicoes manuais) em `ServerStorage.WorldGeneratorBackups`.

Por padrao o centro fica em `ORIGIN = Vector3.new(0, 0, 0)`. Altere essa constante antes de executar se o lobby precisar nascer em outro lugar. Depois de gerar, salve o place e adicione manualmente as interacoes desejadas. Em Play, confira colisao dos edificios, leitura das placas, caminhos livres e enquadramento dos portais.

## Grasslands

Execute cada arquivo inteiro na Command Bar do Roblox Studio, em **Edit**, nesta ordem:

1. `01_Grasslands.luau`: mapa, spawns, destinos, portais, arena e marcador de respawn.
2. `02_MobModels.luau`: modelos de Bushling, Wolf, Boar e Dire Bear.
3. `../ui-generators/23_BossBar.luau`: boss bar e template BillboardGui do contador.

Salve o place antes de Play e sincronize os scripts Common pelo Rojo. O gerador de UI geral deve ser executado antes do gerador de boss bar, pois substitui a pasta de templates.

O mapa comeÃ§a em `ORIGIN = Vector3.new(0, 0, 1000)`, configurÃ¡vel no primeiro arquivo. Bushlings aparecem no inÃ­cio, Wolves no meio e Boars no fim. O portal final leva a uma arena fechada de 230 Ã— 260 studs; o portal no fundo da entrada retorna Ã  Grasslands. A iluminaÃ§Ã£o da caverna Ã© local e nÃ£o interrompe a mÃºsica atual.

Estrutura: `Workspace.Maps.Grasslands`, `MobSpawns.Grasslands`, `ZoneTeleportes`, `ZonePortals.Grasslands`, `ZoneRegions.DireBearCave` e `BossRespawns.Grasslands`. Spawns sÃ£o Parts 1Ã—1Ã—1 invisÃ­veis, ancoradas, sem colisÃ£o, nomeadas apenas com o nome do mob. O servidor acrescenta o identificador de ocupaÃ§Ã£o durante Play.

Os modelos ficam em `ReplicatedStorage.Mobs.Grasslands`, com Humanoid, Animator e membros unidos por Motor6D. SÃ£o rigs procedurais editÃ¡veis; animaÃ§Ãµes publicadas precisam ser compatÃ­veis com suas juntas. O Dire Bear Ã© ajustado para 15 studs pelo sistema existente.

A boss bar aparece para cada jogador a atÃ© 160 studs de um boss vivo. Mostra nome, nÃ­vel e HP. Ao morrer, o contador flutuante mostra os 30 segundos restantes em `BossRespawns`; a barra comum nÃ£o Ã© criada para o boss.

Reexecutar os geradores preserva versÃµes anteriores em `ServerStorage.WorldGeneratorBackups` ou `RPGUIBackups`. Spawns antigos fora de `MobSpawns.Grasslands` sÃ£o preservados: remova ou arquive manualmente os que nÃ£o quiser manter.

ValidaÃ§Ã£o no Studio: entre na Grasslands pelo seletor, percorra os trÃªs grupos, atravesse os portais nos dois sentidos e confira a iluminaÃ§Ã£o; com dois jogadores, verifique alcance da boss bar, morte e respawn. Teste M1 andando e virando. A mÃºsica deve continuar na mesma posiÃ§Ã£o ao entrar na caverna.

## Revis?o compacta

A ?rea externa agora mede 160 ? 330 studs (antes 240 ? 650), com fechamento cont?nuo nos quatro lados, pared?es em camadas e entrada da caverna integrada ? borda final. A decora??o inclui ?rvores, flores, arbustos, pedras, lago ornamental, lanternas e pra?a com placa. As clareiras dos mobs e a passagem dos portais ficam livres de obst?culos. A arena do boss mant?m seu tamanho e recebe forma??es nas bordas.

Para aplicar esta revis?o, execute novamente apenas `01_Grasslands.luau` em Edit e salve. Os spawns e destinos s?o reposicionados junto com o mapa; a vers?o anterior fica em `ServerStorage.WorldGeneratorBackups`.

## Contorno org?nico

A vers?o atual substitui o ret?ngulo por um vale assim?trico com cerca de 340 studs de comprimento e largura vari?vel, chegando a 250 studs. Pared?es acompanham as reentr?ncias e expans?es laterais; tr?s terra?os baixos t?m rampas de acesso. A trilha, as lanternas, as clareiras e os spawns acompanham o percurso curvo at? a caverna. A arena do Dire Bear mant?m sua geometria. Aplique executando novamente apenas `01_Grasslands.luau` em Edit.

## Mobs e anima??o de drops

Execute novamente `02_MobModels.luau` em Edit para instalar as novas silhuetas com focinhos, patas, folhas e pelagem em camadas. Execute `../ui-generators/24_LootRewards.luau` para instalar a anima??o de recompensa. Salve o place e sincronize Common. O efeito aparece apenas para o jogador que recebeu drops de mobs; mostra quantidade efetivamente adicionada, agrupa itens pendentes iguais e destaca raridades. Edite o card e a part?cula em `StarterGui.LootRewards`. Os rigs anteriores s?o preservados no backup. Confira as anima??es dos rigs e o efeito em Play.
