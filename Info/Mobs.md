# Mobs da zona

Modelos e VFX de ataques não foram criados. Use modelos com `Humanoid`, `HumanoidRootPart` e `PrimaryPart` em `ReplicatedStorage.Mobs`, com nomes exatos: `Bushling`, `Wolf`, `Boar`, `Dire Bear`. Crie os pontos correspondentes em `Workspace.MobSpawns`; coloque o ponto `Dire Bear` dentro da sua caverna. O fluxo existente inicializa esses pontos. O boss é normalizado para 15 studs de altura (personagem padrão de aproximadamente 5 studs).

Os indicators usam os templates existentes `ReplicatedStorage.Resources.Indicators.Square` e `Circle` (nomes aceitos sem distinção de maiúsculas). São clonados somente no cliente. A API recebe tamanho de chão X/Z e espessura Y; Circle converte para o eixo X do Cylinder e deita o cilindro. Dano usa volumes matemáticos no servidor, sem Parts de hitbox replicadas.

`tools/ui-generators/05_Combat.luau` gera também `Attack.Debuffs`. Execute em Edit para salvar a área editável; telas antigas recebem a área durante a inicialização como compatibilidade.

| Mob | Vida | Ataque antes da defesa | Ataque básico |
|---|---:|---:|---|
| Bushling | 45 | 5 | Frente 4×4 studs, veneno |
| Boar | 120 | 12 | Frente 6×6 studs |
| Wolf | 180 | 16 | Frente 10×9 studs |
| Dire Bear | 2400 | 30 | Patada frontal 16×13 studs |

Todos os básicos têm aviso de 0,65 s. Dimensões, vida e intervalos estão em `Common/src/Shared/MobCombatConfig.luau`.

## Assets de ataques a produzir

- **Bushling / Spikes:** marca círculos de diâmetro 6 sob todos os jogadores vivos a até 30 studs. As posições ficam fixas; após 1,2 s os espinhos devem subir. Dano 1,2×, uma vez por alvo mesmo com círculos sobrepostos. Básico e spikes aplicam Poison quando causam dano: 2 HP/s por 10 s; reaplicar renova, sem somar instâncias. Ícone de Campfire em Debuffs e HP verde com `[POISON]`.
- **Wolf / TailSpin:** círculo de raio 10, aviso 0,8 s; depois gira por 2 s (duas voltas por segundo). Dano 1,25× uma vez por jogador por giro completo da skill, inclusive quem entrar durante os 2 s. Knockback de intensidade 65, sem ragdoll.
- **Boar / Rush:** faixa frontal 7×36, aviso 1,1 s. Corre até 32 studs a 38 studs/s. Hitbox frontal percorre todo o deslocamento; uma aplicação por jogador, dano 1,6× e knockback 45. Para em obstáculos, direção travada no início.
- **Dire Bear / Basic:** uma patada frontal, aviso 0,65 s, dano 1×.
- **Dire Bear / GroundSlam:** levantar as duas patas e bater no chão. Círculo raio 16, aviso 1,5 s; dano 1,8× e knockback 55.
- **Dire Bear / DoubleSwipe:** duas patadas alternadas, cada uma com faixa frontal 22×16 e aviso 0,65 s; intervalo 0,25 s entre impactos e dano 1,2× por patada.
- **Dire Bear / Roar:** inspirar e rugir, onda circular raio 24. Aviso 1,8 s; dano 1,1× e knockback 75. Sem stun e sem ragdoll.

O boss alterna GroundSlam → DoubleSwipe → Roar, com 6 s entre skills e básicos nos intervalos. O atributo replicado `Attack` informa o ataque em andamento para integrar animações/VFX futuros.

Loot do boss usa equipamentos existentes da zona: Fang Daggers (35%), Talisman of the Wild, Clawed Pendant e Cloak of Hide (30% cada), além de 8 Wilderbone garantidos, 250 Gold e 1800 XP. Apenas participantes no HitList recebem recompensas. Respawn de 120 s.

## Verificação

Compilação pelo Luau CLI e harness de UI/Poison. Física, modelos, chão da caverna, knockback e leitura visual devem ser testados no Studio com os assets. Testar esquiva após aviso, entrada tardia no giro, rush contra parede, morte durante windup e respawn envenenado.
