# Leaderboards globais

Execute `tools/ui-generators/22_Leaderboards.luau` na Command Bar em Edit, salve o place e sincronize os scripts. Ele cria `StarterGui.Leaderboards` (ScreenGui) com quatro SurfaceGuis e templates de linha. Cada Adornee aponta para `Workspace.Leaderboards.<Gold|Kills|Donations|PlayTime>.IMG`; o cliente também resolve as partes quando chegam por streaming. Se a tela estiver na face errada, ajuste `Face` no SurfaceGui salvo (padrão Front).

Cada ranking usa um OrderedDataStore global ao universo. Mostra os 25 maiores valores positivos. Gold representa o saldo atual; Kills é o total de mortes de mobs; PlayTime usa segundos persistidos; Donations é o total numérico de doações confirmadas.

O servidor acompanha alterações dos dados em memória, grava valores alterados a cada 60 segundos, ao sair e no fechamento do servidor. Falhas de gravação deixam o valor pendente para nova tentativa. As listas são consultadas a cada 90 segundos; portanto, não são rankings instantâneos. Falhas de leitura preservam a última lista e mostram mensagem de indisponibilidade. Configuração em `Shared/LeaderboardConfig.luau`.

Isso publica estatísticas nos rankings; não força uma gravação completa do perfil. O DataService continua responsável pela persistência do inventário e demais dados. Os valores saem do perfil no servidor, sem RemoteEvent que permita ao cliente escolher pontuações.

Donations foi adicionado ao template do perfil, mas não existe ProcessReceipt de doações neste projeto. Incremente `PlayerData.Donations` somente a partir de um recibo validado e processado de forma idempotente. IDs e valores dos produtos precisam ser definidos na integração de compras; nenhuma compra fictícia ou remote de doação foi criado.

Studio usa stores com sufixo `Studio_`, separados de produção. Para testar persistência, publique o place e habilite acesso a API Services no Studio. Teste duas sessões/servidores: altere Gold e Kills enquanto online, aguarde os intervalos, confira o outro servidor, saia e entre novamente. Verifique também PlayTime, ordenação, inventário de dados vazio e falha de API. Compilação e harness de UI não substituem esses testes de DataStore.
