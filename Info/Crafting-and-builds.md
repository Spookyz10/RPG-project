# Crafting e equipamentos da zona

No Studio, fora do Play, execute `tools/ui-generators/20_Crafting.luau` para salvar a tela de crafting e `06_Inventory.luau` para incluir CPWR na ficha de equipamento. `00_All.luau` também inclui tudo. Os geradores guardam backup das telas anteriores. Sincronize os scripts e salve o place antes de jogar. Acesse pelo Blacksmith → Crafting.

A UI mostra nível, descrição da passiva, custo em Gold e contagem de materiais. O servidor valida receita, nível, materiais e espaço, fabrica uma unidade por solicitação e avança a quest CraftItem. Materiais consumidos liberam espaço para o resultado. Falhas de validação não consomem recursos.

## Fang Daggers

Exclusiva de crafting: removida dos drops de Wolf e Dire Bear. Continua sendo a arma mais forte da zona, com 12 Attack e Fury.

## Direfang Sword

Espada Solo Rare, nível 10, 9 Attack, drop de 35% do Dire Bear. Maul adiciona 4 Attack a cada quarto acerto com dano, antes dos multiplicadores de skill e crítico. Prévias, ataques cancelados e dano zero não avançam nem consomem a contagem; desequipar reinicia. Cada vítima de um ataque em área conta como um acerto. A contribuição média da arma é 10 Attack por acerto sem outros modificadores, abaixo dos 12 da Fang Daggers mesmo antes de Fury.

O ícone é provisório. Para exibir a arma equipada, adicione um Model chamado `Direfang Sword` em `ReplicatedStorage.Resources.Weapons`, com uma peça `Handle` e, opcionalmente, um Attachment `GripPoint`.

### Receita e passiva da Fang Daggers

ID canônico preservado: `Fang Dagger`; nome exibido: `Fang Daggers`.

Receita: nível 12, 75 Gold, 8 Wolf's Fang, 5 Wilderbone, 3 Dark Ivy.

Fury gera uma carga a cada 15 segundos enquanto equipada e viva, máximo 2. Um acerto que cause dano consome uma carga e garante crítico com +150 pontos percentuais de Critical Power. Errar ou ter o ataque cancelado não consome. Trocar de arma ou respawnar reinicia as cargas; trocar acessórios não. Em ataques de área, cada vítima atingida consome uma carga. As cargas aparecem em Attack.Buffs.

Critical Power agora entra no cálculo e aparece nos detalhes/tooltip do item. O crítico base é 2×: com 20 Critical Power e Fury, o multiplicador é 3,7× antes da defesa. Stats ausentes em itens antigos contam como zero.

## Novos drops e ideias de build

| Mob | Equipamento | Passiva | Chance |
|---|---|---|---:|
| Bushling | Briar Ring | Venom: acertos marcam o alvo por 6 s para Venom Hunter | 8% |
| Bushling | Bloom Pendant | Regrowth: cada 5 acertos cura 4% da vida máxima | 6% |
| Wolf | Hunter's Charm | Venom Hunter: +20% dano contra alvos marcados | 7% |
| Wolf | Bloodfang Ring | Predator: críticos curam 8% do dano causado | 5% |
| Boar | Ironhide Band | Bulwark: -15% dano recebido com pelo menos 70% de vida | 7% |
| Boar | Tuskguard Mantle | Last Stand: -25% dano recebido com até 35% de vida | 5% |
| Dire Bear | Direheart Pendant | Berserker: +25% dano com até 40% de vida | 15% |
| Dire Bear | Crown of the Hunt | Executioner: +25% dano contra alvos com até 30% de vida | 12% |

Materiais novos: Boar Tusk (65% no Boar) e Dire Claw (100% no Dire Bear). Ícones dos novos itens reutilizam placeholders existentes; nenhum modelo novo é necessário para os acessórios.

Builds sugeridas:

- **Crítico e sustain:** Fang Daggers + Bloodfang Ring + Bloom Pendant.
- **Marca e dano consistente:** Briar Ring + Hunter's Charm.
- **Sobrevivência:** Ironhide Band + Bloom Pendant + Tuskguard Mantle.
- **Berserker:** Direheart Pendant + Crown of the Hunt + Tuskguard Mantle.

Briar Ring, Hunter's Charm, Ironhide Band e Direheart Pendant também têm receitas. Venom é uma marca de sinergia, não o Poison de dano periódico do Bushling. Reduções defensivas se aplicam aos acertos do DamageHandler, não ao Poison fixo de 2 HP/s.

Verificações automatizadas: `tools/verify_equipment.py --luau PATH`, `tools/verify_ui.py --luau PATH` e compilação Luau. O harness usa mocks; a leitura visual, o fluxo do NPC e a física precisam de Play no Studio.
