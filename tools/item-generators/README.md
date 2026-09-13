# Estudos de modelos — versão 2

Cole todo o arquivo `00_ItemModels.luau` na Command Bar do Roblox Studio, com Play parado.
Ele seleciona uma galeria em `Workspace.ItemModelStudy`, na posição configurável
`ORIGIN = Vector3.new(0, 20, -180)`. Selecione um dos modelos no Explorer e pressione
**F** para enquadrá-lo. As 25 peças estão organizadas em cinco colunas sobre pedestais.
Joias e materiais foram ampliados para inspeção; estas não são escalas de equipamento.

Este arquivo é somente um estudo visual. Não instala assets em Resources, não altera
itens, inventário, UI, drops ou equipamento e não cria scripts de runtime.
Wooden Sword é o item inicial do jogo. A galeria continua sendo apenas uma referência
visual e não instala seu modelo em `Resources.Weapons`.

## Construção

- Madeira com veios e nó esculpidos, guarda de carvalho e empunhadura enrolada.
- Presas curvas com raiz escurecida, ponta afilada, colares e acabamento em osso.
- Anéis vazados com bordas e cravações: espinhos, presas, coroa e sinete de ferro.
- Colares com elos abertos e pingentes de flor, três garras, coração e galhada.
- Frascos com cinco proporções, líquido, gargalo, rolha porosa, cordão e símbolos modelados.
- Couro com dobras, costuras, gola aberta e pelos; Tuskguard tem ombreiras sobrepostas e presas.
- Materiais com anatomias distintas e uma runa de pedra com incrustação e fissuras.

As superfícies usam materiais nativos (Wood, Fabric, Metal, Slate, Grass etc.)
e detalhes geométricos. Não há mapas de textura personalizados, meshes importados
ou downloads de imagens. Tudo pode ser selecionado e editado no Studio.
São modelos de inspeção detalhados, não assets otimizados para produção.

Executar novamente preserva a galeria anterior inteira, movendo-a para
`ServerStorage.ItemModelStudy_Backup_<data>`. Somente galerias marcadas por este
gerador são movidas; uma pasta alheia com o mesmo nome interrompe a publicação.
Os assets que você eventualmente criou executando a versão 1 no Studio continuam
onde estavam; esta versão não modifica Resources nem arquivos de place.

Aparência, transparência e iluminação final precisam ser conferidas no Studio.
