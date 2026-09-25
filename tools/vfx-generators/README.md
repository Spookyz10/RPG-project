# Combat VFX e animacoes de mobs

## Revisao atual (setembro de 2026)

A revisao atual usa `03_CombatPolish.luau` e `04_MobMotion.luau`, executados em **Edit Mode** depois de sincronizar os scripts pelo Rojo. O instalador antigo abaixo serve como base; roda-lo novamente substitui o acabamento atual.

- `03_CombatPolish.luau`: 40 templates e 192 camadas de ParticleEmitter em `ReplicatedStorage.Resources.CombatVFX`. Reaproveita texturas de `ServerStorage.VFX`, preservando os flipbooks, com um anel transparente para ondas de pressao. As copias anteriores ficam em `ServerStorage.RPGVFXBackups`.
- `04_MobMotion.luau`: 37 KeyframeSequences em `ReplicatedStorage.Resources.MobMotion`, divididas pelos oito mobs. Inclui Idle, Walk, Basic e cada skill existente. Nao adiciona animacao de morte.
- `05_VerifyCombatPolish.luau`: execute no **Client durante Play**. Usa clones isolados, testa movimento, todas as poses de ataque, emissao atrasada, cancelamento, expiracao de todos os bursts, status, morte e carregamento das texturas. Limpa os objetos de teste mesmo em falhas. Nao modifica dados de jogadores.

`MobAnimations` reproduz localmente as poses nos Motor6Ds durante PreSimulation. Movimento e dano continuam no servidor. `AttackStartedAt` sincroniza as poses com o ataque; o ciclo de caminhada acompanha o deslocamento e a escala do rig. Os clips podem ser editados como KeyframeSequences; essa reproducao nao exige IDs publicados. Reinicie o Play depois de editar clips, pois o cliente compila e guarda as poses em cache. O player atual interpola CFrames linearmente entre as poses amostradas; nao interpreta markers nem curvas de easing do Animation Editor.

Os templates usam `EmitCount`, `EmitDelay` e `EmitDuration`; o runtime agenda as camadas em um unico Heartbeat. Poeira marcada `WorldSpace` fica no mundo, enquanto os cortes acompanham a entidade. Safeguard e Lure Jab usam o mesmo ciclo de vida dos demais status. Morte, remocao, distancia e cancelamento limpam os efeitos; bursts tem limite de 80 simultaneos. O rugido emite no instante do dano.

Escalas de referencia: GroundSlam 32 studs; salto do urso 22; Cavefall 14; rugido 48; TailSpin 20; HeartSlam 36; SporeBloom/SporeEcho 14/20; Cyclone 10; Ground Break 12. Sao diametros visuais; os hitboxes existentes permanecem autoritativos. A cena de comparacao usou o Dire Bear escalado para seus 15 studs de altura de gameplay.

Os assets gerados pertencem ao place: **salve o place no Studio** para persistir as alteracoes. Rojo sincroniza o codigo, mas nao recria esses assets automaticamente. Aplique os instaladores tambem em outros places que usam o mesmo codigo.

## Documentacao do instalador original


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

Compilacao Luau; analise dos novos modulos cliente e geradores com definicoes Roblox; harnesses `verify_mob_attacks.py`, `verify_equipment.py` e `verify_combat_vfx.py`. Os testes usam mocks. Aparencia, timing percebido, carregamento das texturas e replicacao real precisam de Play no Studio; os resultados historicos dos mocks nao substituem a verificacao em Studio descrita acima.
