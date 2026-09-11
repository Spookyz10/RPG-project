# Combat VFX - gerador de Edit Mode

## Instalar e testar

1. Sincronize os scripts pelo Rojo e pare o Play no Studio.
2. Cole TODO `00_VFXLab.luau` na Command Bar e execute.
3. Os 21 templates ficam em `ReplicatedStorage.Resources.CombatVFX`. Salve o place. Repita no outro place se Lobbies e Raids usam arquivos separados.
4. Entre em Play: ataques e status agora reproduzem esses templates automaticamente.

O gerador cria os assets no Studio; sincronizar apenas os scripts nao cria os modelos. Assets ausentes produzem um aviso e o combate continua funcionando.

## Organizacao

| Pasta | Templates |
|---|---|
| Statuses | Poison, Venom, Fury, Lure Jab, Safeguard |
| Attacks | SpikeWarning, Spikes, Melee, DoubleSwipe, GroundSlam, Roar, TailSpin, Rush |
| Skills | Basic, Cyclone, Lure Jab, Ground Break, Blessing |
| Impacts | Regrowth, Maul |

Spikes usam cunhas verdes com bordas luminosas e rochas. GroundSlam e Ground Break usam rochas e ondas/rachaduras. Cortes usam arcos de cunhas neon; Roar usa ondas concentricas; TailSpin e Cyclone usam faixas de vento; Rush usa ribbons e poeira. Safeguard tem uma esfera ForceField e selo circular. Sao modelos procedurais feitos de Parts/WedgeParts, beams e particulas, sem meshes externos.

Os modelos sao visuais, ancorados e sem colisao, toque ou consulta de hitbox. O servidor controla dano e momento dos ataques; os clientes clonam e animam os templates. Spikes sobem do chao; ondas expandem; cortes e ciclones giram; as pecas desaparecem ao final. Rush e TailSpin acompanham o mob e encerram quando o ataque observado termina. A duracao tambem limita a vida das copias.

Poison, Venom, Fury, Lure Jab e Safeguard acompanham a entidade, sem duplicar emissores em refresh. Atributos replicados restauram status para quem entra depois ou recebe entidades por streaming. Morte/remocao limpa os efeitos. Existe limite de 80 bursts simultaneos por cliente e distancia visual de 240 studs.

Safeguard antes executava Cyclone: agora aplica a protecao anunciada na skill, reduzindo dano recebido em 70% durante 5 segundos pelo StatusEffectManager.

## Editar e experimentar

`Workspace.RPGVFXLab` mostra copias de todos os templates, separadas em uma grade. Essa galeria e ocultada localmente durante Play. **O jogo usa Resources: edite o template nessa pasta para alterar o resultado final.** Edicoes na galeria nao sao copiadas automaticamente.

Selecione um Model em Resources ou na galeria e execute `01_PreviewSelected.luau` na Command Bar, fora do Play. Ele anima uma copia temporaria por ate 3 segundos, incluindo subida, giro, expansao, beams e particulas. Para presets em Resources, a copia aparece no foco da camera.

O plugin de Emit continua utilizavel. ParticleEmitters ficam desativados no template; `EmitCount` sugere a quantidade de cada camada. Beams nao possuem Emit: use Enabled, ou o script de previa. `Duration`, `RiseDistance`, `SpinSpeed` e `ExpandFrom` controlam a animacao no runtime. `PreviewDuration` controla a janela dos beams de burst.

Reexecutar o gerador guarda os templates e a galeria anteriores em `ServerStorage.RPGVFXBackups`, tentando registrar um waypoint de Undo quando o Studio permitir. A Command Bar nao depende de TryBeginRecording; os backups funcionam mesmo sem Undo. Ele preserva outros assets de Resources.

## Texturas e referencias

- Anel branco: `rbxassetid://1266170131`, do exemplo oficial: https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter
- Texturas locais verificadas na instalacao Roblox: smoke_main.dds, sparkles_main.dds, fire_sparks_main.dds, SquareParticle.png, em `rbxasset://textures/particles/`.
- Beams: https://create.roblox.com/docs/effects/beams
- Pivots e escala: https://create.roblox.com/docs/reference/engine/classes/Model

Se o anel online nao carregar, substitua TEXTURES.Ring por um asset de anel branco transparente disponivel na sua experiencia.

## Validacao

Compilacao Luau; analise dos novos modulos cliente e geradores com definicoes Roblox; harnesses `verify_mob_attacks.py`, `verify_equipment.py` e `verify_combat_vfx.py`. Os testes usam mocks. Aparencia, timing percebido, carregamento das texturas e replicacao real precisam de Play no Studio; esta sessao nao tem acesso direto ao Studio.
