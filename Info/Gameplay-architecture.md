# Arquitetura de gameplay

## Mobs

`Modules/Mobs/Behaviors` contém apenas `Bushling`, `Wolf`, `Boar` e `Dire Bear`. Cada módulo declara seu básico e a sequência de skills. O registro em `Mobs/init.luau` carrega os behaviors automaticamente pelo nome.

- `Controller`: seleção de alvo, perseguição, cooldowns e sessão de combate.
- `CombatContext`: cancelamento, projeção no chão, indicators, consulta de volumes, aplicação de dano e knockback.
- `Attacks`: execução de Melee, Spikes, TailSpin, Rush, GroundSlam e Roar. DoubleSwipe reutiliza Melee com dois ataques.
- `Shared/MobCombatConfig`: números de balanceamento, sem seleção de behavior por nome dentro do controlador.

O token de sessão impede que um ataque antigo continue causando dano depois de cancelado. Indicators são enviados ao cliente; a decisão de acerto e o dano ficam no servidor. Novo mob: crie sua definição em Behaviors, dados de balanceamento/loot e modelo/spawn com o mesmo nome. Nova skill: adicione um executor em Attacks e referencie na definição.

Os behaviors antigos, BasicMeleeBehavior e ZoneBehavior foram removidos. Um spawn sem behavior registrado gera aviso e não cria um mob inerte. A quest Tutorial2 agora aponta para Dire Bear.

## Status effects: buffs e debuffs

`StatusEffectManager` substitui BuffsManager e PoisonManager. Ele é responsável por aplicação, renovação, prioridade, stacks, tick, expiração, consulta e limpeza. Não conhece regras de Poison, Fury ou qualquer outro efeito específico.

`Shared/StatusEffects` define duração, intervalo, categoria, ícone, tags, modificadores e apresentação opcional da HP bar. `Modules/StatusEffectBehaviors` registra callbacks opcionais (`OnApply`, `OnTick`, `OnRemove`) pelo nome. Apenas callbacks do servidor podem aplicar dano.

API:

```lua
StatusEffects:Apply(character, "Poison", { Source = caster })
StatusEffects:Apply(character, "Fury", { Stacks = 2 })
StatusEffects:HasEffect(character, "Venom")
StatusEffects:GetEffectsByTag(character, "DamageOverTime")
StatusEffects:Remove(character, "Poison")
StatusEffects:ClearEntity(character)
```

Uma aplicação de mesma prioridade renova/substitui aquela entrada. Prioridades diferentes coexistem; a maior fica ativa, e a inferior retoma quando necessário. Efeitos suprimidos não acumulam ticks. `Stacks` define a quantidade atual, limitada por `MaxStacks`; a regra que gera ou consome cargas pertence à passiva. Duração ausente indica efeito persistente, removido explicitamente pelo dono. Limpeza remove apenas modificadores pertencentes ao efeito, preservando outros sistemas.

Um único scheduler em `Server/StatusEffects.server.luau` chama `Step`. O mesmo arquivo assina `StatusEffectChanged` e `StatusEffectRemoved` no EventBus e transmite a apresentação ao cliente. Não há task de expiração ou loop de dano específico por efeito. A UI escolhe Buffs/Debuffs e o ícone pelos metadados; Fury usa a mesma UI. A HP bar também lê metadados, sem condição específica para Poison.

## Passivas e combate

`DamageHandler` publica fases no EventBus: `BeforeAttack`, `BeforeIncomingDamage`, `HitConfirmed`, `HitApplied` e os eventos já existentes de dano/crítico/morte. `EquipmentPassives` assina essas fases e despacha para os módulos ativos em `PassiveBehaviors`, com estado separado por passiva e origem.

Nenhuma regra de item pertence ao DamageHandler. Fury controla geração/consumo das cargas, e o status manager publica seu estado visual; Venom e Venom Hunter compartilham o status de marca. Consulte `PassiveBehaviors/README.md` para o contrato dos hooks. Callbacks de combate/status devem ser síncronos e não ceder execução.

## Dependências e verificação

Os mecanismos necessários já existem no projeto (EventBus, ModifierSystem e remotes); esta migração não exige novos pacotes Wally. Os dois projetos Rojo já mapeiam as pastas Shared, Modules, Client e Server recursivamente, incluindo os novos módulos e bootstrap.

- `tools/verify_equipment.py`: módulos reais de passivas, EventBus, status, modificadores, dano e crafting sob relógio controlado.
- `tools/verify_mob_attacks.py`: behaviors reais, execuções de ataques, deduplicação, avisos, duração e cancelamento em mocks.
- `tools/verify_ui.py`: UI salva, recipes, buffs/debuffs e contratos de layout.
- Compilação Luau de `Common/src`.

Esses testes não simulam a física do Roblox nem renderizam o place. Verificar no Studio os modelos/spawns, colisões, knockback e a chegada de remotes na UI. Não foram criados modelos ou VFX de ataques.
