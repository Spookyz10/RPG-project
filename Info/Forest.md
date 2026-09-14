# Forest ? zona 2

## Instala??o

Com Play parado, execute os arquivos completos na Command Bar do Studio:

1. `tools/world-generators/04_Forest.luau`: mapa Forest v2.
2. `tools/world-generators/05_ForestMobModels.luau`: quatro rigs edit?veis.
3. **Reexecute** `tools/world-generators/06_ForestSpawnsAndLighting.luau`: 13 spawns, ilumina??o, regi?o da arena e marcador de respawn do boss.
4. `tools/world-generators/07_ForestCombatAssets.luau`: 11 templates de ataques e modelos de Thornwood Blade / Heartwood Cleaver.
5. Sincronize Common pelo Rojo e salve antes de Play. A Forest aparece no seletor automaticamente pelo módulo em `Shared.Zones.Forest`; reexecute 06 para criar seu destino em `Workspace.ZoneTeleporters.Forest`.

Os geradores preservam os objetos substitu?dos em `ServerStorage.WorldGeneratorBackups`. Para atualizar combate em um mapa j? gerado, basta executar 06 e 07. Geradores gerais de VFX podem substituir sua pasta de assets: execute 07 por ?ltimo. N?o h? necessidade de regenerar a UI do Blacksmith; as receitas v?m de CraftingRecipes.

A Forest ainda n?o tem entrada no seletor de zonas nem quests pr?prias. A integra??o desta etapa ? combate no mapa, recompensas e crafting. ?cones continuam ausentes. As passivas de equipamentos listadas no fim continuam propostas, sem efeitos ativos.

## Organiza??o

| Conte?do | Local |
|---|---|
| Mapa, nove pontos de interesse e marcadores | Workspace.Maps.Forest |
| Rigs | ReplicatedStorage.Mobs.Forest |
| 11 Mosscaps, 9 Stags, 7 Sentinels, 1 Elderbark | Workspace.MobSpawns.Forest |
| Regi?o da ilumina??o | Workspace.ZoneRegions.Forest |
| Limite do combate do boss | Workspace.ZoneRegions.Elderbark Heartgrove |
| Contador de respawn | Workspace.BossRespawns.Forest.Elderbark |
| Lighting edit?vel | ReplicatedStorage.Resources.LightingTemplates.Forest |
| Templates visuais | ReplicatedStorage.Resources.CombatVFX.Attacks |
| Armas equip?veis | ReplicatedStorage.Resources.Weapons |
| Stats, drops e recompensas | Common/src/Shared/MobsData/Forest |
| Configura??o do combate | Common/src/Shared/MobCombatConfig.luau |
| Behaviors e ataques | Common/src/Modules/Mobs/Behaviors e Attacks |
| Receitas do Blacksmith | Common/src/Shared/CraftingRecipes.luau |

## Explora??o e apar?ncia

Bacia org?nica de aproximadamente 580 ? 580 studs, com nove destinos e doze trilhas curvas formando quatro circuitos. Pilgrim Gate e Crossroads d?o acesso ao Spore Garden, Moonwater Garden e ? ?rvore central de 105 studs. O jogador encontra acampamento, tronco ca?do sobre a trilha, cachoeira, observat?rio, santu?rio lateral, mirante com rampa e o bosque de Elderbark. ?rvores secund?rias t?m 43?70 studs. Vegeta??o pequena e ra?zes ornamentais n?o colidem; ?gua ? decorativa.

Mosscap tem chap?u em camadas, guelras radiais e mochila de musgo. Stag tem galhadas folhadas e joelhos articulados. Sentinel ? uma ru?na ambulante com rel?quia suspensa. Elderbark tem corpo pr?prio de tronco retorcido, bra?os assim?tricos e coroa de galhos. Motor6D controla articula??es; WeldConstraint prende detalhes.

Lighting: tarde dourada, sombras verde-azuladas, n?voa suave, raios de sol e bloom discreto. Propriedades ficam nos Attributes do template; efeitos s?o filhos edit?veis. O cliente regional aplica o template somente dentro da Forest e restaura o padr?o ao sair/perder o personagem. A caverna mant?m prioridade. N?o altera o Lighting global em Edit. Reexecute 06 depois de mover, regenerar ou redimensionar mapa/rigs.

## Combate ativo

Valores iniciais, antes de defesa; ainda precisam de balanceamento jogado.

| Mob | N?vel | HP | Ataque | Defesa | Velocidade | XP / Gold | Respawn |
|---|---:|---:|---:|---:|---:|---|---|
| Mosscap | 16 | 280 | 17 | 3 | 11 | 340 / 32 | 10 s |
| Thornback Stag | 19 | 410 | 22 | 4 | 18 | 460 / 42 | 11 s |
| Hollow Sentinel | 22 | 620 | 27 | 7 | 10 | 620 / 55 | 13 s |
| Elderbark | 25 | 6500 | 38 | 9 | 9 | 3200 / 400 | 120 s |

B?sicos comuns t?m aviso de 0,65 s; Elderbark usa 0,85 s. Todos os ataques usam os indicators existentes e dano autoritativo de CombatContext. A margem de hitbox j? existente ? de 1 stud por lado; altura de dano m?nima de 40 studs: esquivar lateralmente ? o recurso confi?vel, n?o pular sobre o aviso.

- **Mosscap / SporeBloom:** anuncia dois c?rculos fixos no in?cio. Impactos em 1,2 s (raio 7) e 2 s (raio 10). Sair da ?rea maior evita ambos. Um alvo recebe no m?ximo um acerto de 1,2? por uso, inclusive se cruzar as duas ondas. Recarga 9 s, alcance de ativa??o 14.
- **Stag / AntlerRush:** aviso frontal 8?32 por 1,3 s. Corre 26 studs a 30 studs/s, dire??o travada, para em obst?culos. Acerto ?nico de 1,4?, knockback 35. Recupera??o de 0,9 s ap?s a corrida permite contra-atacar. Recarga 10 s, alcance 30.
- **Sentinel / RootLanes:** duas faixas frontais 10?28, separadas por uma faixa central estreita. Esquerda explode em 1,1 s, direita em 1,8 s, ambas anunciadas no in?cio. ? poss?vel trocar para a metade j? atingida. Cada faixa causa 0,8? uma vez por jogador. Recarga 11 s, alcance 28.
- **Elderbark / HeartSlam:** c?rculo fixo de raio 18, aviso 1,5 s, dano 1,5? e knockback 35; recarga 14 s.
- **Elderbark / MarkedRoots:** marca at? tr?s jogadores vivos mais pr?ximos a at? 55 studs, fixa as posi??es e avisa por 1,6 s. C?rculos de raio 6 causam 1,2?; sobreposi??es compartilham deduplica??o. Sair da posi??o marcada evita o ataque. Recarga 16 s.
- **Elderbark / RootSweep:** faixa frontal 26?20, aviso 1,2 s, dano 1,4?; recarga 13 s. Recompensa posicionamento lateral/traseiro.

Elderbark alterna as habilidades dispon?veis respeitando alcance, recarga e **5 s de intervalo global ap?s cada habilidade**, usando b?sicos entre elas. Mobs comuns t?m intervalo global de 2 s. O Controller conserva o comportamento anterior para mobs sem SkillRecovery. Reset/death cancela a sess?o; ataques n?o mant?m tarefas independentes de dano ap?s cancelamento. Ranges e leashes evitam persegui??o pela zona inteira. A regi?o quadrada do boss mede 112?70?112; o Controller reinicia o boss quando n?o h? alvo eleg?vel nela.

N?o h? invulnerabilidade, cura infinita, veneno escondido, enrage ou invoca??es nesta vers?o. Os efeitos mostram os ataques; anima??es esquel?ticas publicadas espec?ficas dos rigs ainda precisam ser produzidas. VFX tem dura??o limitada, descarte por dist?ncia e cleanup pela infraestrutura existente.

## Drops e crafting ativos

Drops usam o pipeline existente: apenas participantes registrados em HitList recebem recompensas. N?o h? recompensa global. Cada material comum tem chance de 75%, quantidade 1; Elderbark fornece 3 Elder Heartwood garantidos.

| Item / ID exato | Fonte | Craft?vel? | Receita ativa |
|---|---|---|---|
| Spore Silk | Mosscap, 75% | N?o | Ingrediente |
| Thorn Antler | Stag, 75% | N?o | Ingrediente |
| Runic Bark | Sentinel, 75% | N?o | Ingrediente |
| Elder Heartwood | Elderbark, 3 garantidos | N?o | Ingrediente |
| Sporeweave Mantle | Blacksmith, n?vel 16 | Sim | 12 Spore Silk + 4 Runic Bark + 220 Gold |
| Thornwood Blade | Blacksmith, n?vel 18 | Sim | 10 Thorn Antler + 6 Runic Bark + 300 Gold |
| Bramble Loop | Stag, 6% | N?o | Drop exclusivo |
| Moonwater Pendant | Sentinel, 5% | N?o | Drop exclusivo |
| Runebark Vestment | Blacksmith, n?vel 23 | Sim | 16 Runic Bark + 8 Spore Silk + 450 Gold |
| Heartwood Cleaver | Blacksmith, n?vel 25 | Sim | 8 Elder Heartwood + 12 Thorn Antler + 700 Gold |
| Heart of the Grove | Elderbark, 12% | N?o | Drop exclusivo |

Crafting usa a valida??o, trava por jogador e consumo de materiais/Gold existentes no servidor. Sem mudan?as de schema ou IDs. Todos os itens continuam sem ?cone. As armas geradas t?m Handle e GripPoint, compat?veis com WeaponLoader. As armaduras/acess?rios usam seus stats; n?o foram criados cosm?ticos corporais.

## Passivas de equipamento ? futuras, n?o ativas

Todos os equipamentos Forest ainda t?m `Passive = ""`. Propostas para uma etapa dedicada: Deep Roots no Heartwood Cleaver (quinto acerto +5 Attack); Barkskin na Runebark Vestment (primeiro dano -15%, recarga 12 s); Renewal no Heart of the Grove (sexto acerto recupera 3% HP). Revisar intera??o com passivas atuais e impedir reset abusivo por reequipar antes de implementar. Descri??es dos itens n?o prometem esses efeitos.

## Verifica??o

`tools/verify_forest_combat.py --luau <caminho>` executa os m?dulos reais de ataque com mocks: cancelamento, deduplica??o, ordem das faixas, sele??o de tr?s alvos, corrida bloqueada, behaviors, drops e receitas. O compilador Luau valida sintaxe/bytecode. Isso n?o substitui Studio.

Playtest pendente: spawns com p?s no ch?o, persegui??o entre ?rvores, hitboxes/avisos, ataques contra obst?culos, morte durante windup e corrida, sobreposi??o de ra?zes com dois jogadores, boss bar, reset ao sair da arena, timer de 120 s, recompensas somente para participantes e crafting com invent?rio cheio/materiais insuficientes. Conferir grip e anima??es das armas, leitura dos VFX sob a ilumina??o e retorno ? Grasslands sem regress?o.

Boar continua com Attack 9 e Wolf 14; esta integra??o n?o altera essa corre??o.
