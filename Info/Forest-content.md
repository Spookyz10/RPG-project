# Conteúdo da Forest

Esta é a referência atual de loot, crafting e builds da Forest. Os equipamentos produzidos no crafting não aparecem prontos em tabelas de drop.

## Loot

| Mob | Materiais e consumíveis | Equipamento exclusivo |
|---|---|---|
| Mosscap | Spore Silk (85%), Small Health Potion (8%) | Sporecap Pendant (5%) |
| Thornback Stag | Thorn Antler (80%), Small Speed Potion (8%) | Bramble Loop (6%) |
| Hollow Sentinel | Runic Bark (75%), Small Defense Potion (10%) | Moonwater Pendant (5%) |
| Elderbark | 3 Elder Heartwood e 2 Small Health Potions garantidos | Heart of the Grove (12%) |

## Crafting da Forest

| Nível | Resultado | Receita |
|---:|---|---|
| 16 | Sporeweave Mantle | 10 Spore Silk + 180 Gold |
| 18 | Sporethorn Daggers | 8 Spore Silk + 5 Thorn Antler + 260 Gold |
| 19 | Thornwood Blade | 10 Thorn Antler + 5 Spore Silk + 300 Gold |
| 21 | Rune of Resonance | 6 Runic Bark + 6 Spore Silk + 350 Gold |
| 22 | Sentinel Signet | 8 Runic Bark + 6 Thorn Antler + 400 Gold |
| 22 | Runebark Vestment | 14 Runic Bark + 8 Spore Silk + 450 Gold |
| 25 | Grovekeeper Charm | 5 Elder Heartwood + 8 Runic Bark + 600 Gold |
| 25 | Heartwood Cleaver | 6 Elder Heartwood + 10 Runic Bark + 700 Gold |

## Linhas de build

- **Crítico em sequência:** Sporethorn Daggers + Sentinel Signet + Moonwater Pendant. Procs frequentes de crítico e uma proteção carregada ao atacar.
- **Duelista de skills:** Thornwood Blade + Bramble Loop + Sporecap Pendant + Rune of Resonance. Ritmo no terceiro acerto, resposta depois de ser atingido, bônus depois de crítico e skills 15% mais fortes.
- **Tanque agressivo:** Heartwood Cleaver + Sentinel Signet + Heart of the Grove. Reduções periódicas, sustain e dano extra com pouca vida.
- **Sustain seguro:** Heartwood Cleaver + Runebark Vestment + Grovekeeper Charm. Cura cíclica e redução previsível a cada terceiro golpe recebido.

Os itens de Grasslands Briar Ring, Hunter's Charm, Ironhide Band e Direheart Pendant também são exclusivos de crafting. Seus antigos drops diretos foram removidos; os drops exclusivos alternativos dos respectivos mobs continuam ativos.

## Modelos de armas

Os modelos devem ficar em `ReplicatedStorage.Resources.Weapons`, usando exatamente estes nomes:

- `Sporethorn Daggers` — novo e obrigatório para a nova arma aparecer equipada. O mesmo modelo é clonado para as duas mãos.
- `Thornwood Blade` — já possui placeholder do gerador da Forest, mas pode ser substituído pelo modelo definitivo.
- `Heartwood Cleaver` — já possui placeholder do gerador da Forest, mas pode ser substituído pelo modelo definitivo.

Cada um deve ser um `Model` com uma `BasePart` chamada `Handle`. Um `Attachment` chamado `GripPoint` dentro do Handle é opcional e recomendado. Também podem ser usados os atributos `GripPosition` e `GripOrientation` (`Vector3`) no Model para ajuste fino. As peças podem estar sem weld e serão soldadas ao Handle pelo `WeaponLoader`; não deixe partes ancoradas no asset final.
