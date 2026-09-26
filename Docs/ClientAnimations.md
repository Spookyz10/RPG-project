# Animações no cliente e publicação dos clips

A reprodução foi transferida para o cliente: locomoção, idles, golpes, skills e todos os mobs/bosses. O servidor mantém as regras de combate e envia apenas início/nome dos golpes. Criar o Animator no servidor é necessário à replicação nativa de tracks iniciados pelo jogador; isso não executa animações no servidor.

## Preparar sequências e fazer preload são etapas diferentes

Uma KeyframeSequence contém poses locais, não um arquivo de animação publicado para ContentProvider baixar. As sequências atuais são replicadas em Resources e compiladas em cache durante a tela de carregamento. Isso evita percorrer e organizar keyframes no primeiro golpe. O amostrador executa em PreSimulation no cliente e respeita os tempos de início replicados.

Uma Animation com AnimationId publicado pode entrar em um único `ContentProvider:PreloadAsync(listaDeAnimations)`. O carregamento existente coleta automaticamente as Animations dentro de Resources: não precisa escrever preload por nome. Falhas de permissão ou download continuam possíveis; preload não publica nem concede permissão ao asset.

Documentação: https://create.roblox.com/docs/reference/engine/classes/ContentProvider

## Publicação: não confundir com preload nem exportação de arquivo

`RegisterKeyframeSequence` cria IDs temporários para testes locais no Studio. Não transforma os clips em assets publicados utilizáveis no jogo online.

Documentação: https://create.roblox.com/docs/reference/engine/classes/KeyframeSequenceProvider/GetAnimationsAsync

O fluxo oficial documentado no Animation Editor publica um clip por vez: abrir/importar o clip no rig correto, menu `...`, `Publish to Roblox`, selecionar o criador correto e salvar. Use o grupo proprietário quando aplicável e confira as permissões da experiência.

Documentação: https://create.roblox.com/docs/animation/editor

É possível selecionar e exportar várias sequências para um arquivo RBXM; isso é backup/transporte, não publicação de vários AnimationIds.

Documentação: https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations

Não foi confirmado um fluxo oficial de publicação em lote para as KeyframeSequences deste projeto. A API documentada `AssetService:CreateAssetAsync` lista Model, Plugin, Mesh e Image, não Animation. Portanto não se deve usar essa API prometendo publicar estes clips automaticamente. Ferramentas de terceiros precisam ser avaliadas separadamente; não é necessário instalar uma para o preload em lote.

Documentação: https://create.roblox.com/docs/reference/engine/classes/AssetService

## Organização para converter depois

- Fontes de jogador: `ReplicatedStorage.Resources.PlayerMotion`.
- Fontes de NPC: `ReplicatedStorage.Resources.MobMotion/<nome do mob>`; publicar com o rig correspondente de `ReplicatedStorage.Mobs`, preservando hierarquia, escala, Loop e Priority.
- Animações publicadas de locomoção: `ReplicatedStorage.Resources.Animations`.
- Registre cada novo ID pelo caminho completo da fonte: por exemplo `MobMotion/Elderbark/HeartSlam`, não apenas `HeartSlam` ou `Idle`. Nomes se repetem entre rigs.
- Preserve as sequências originais como arquivos-fonte. Os novos IDs precisam ser ligados ao playback nativo; somente criar um objeto Animation ao lado da sequência não substitui o amostrador.

Esta alteração não publicou nem converteu as sequências em IDs online. Elas continuam funcionando pelo amostrador agora inteiramente cliente. A publicação e a substituição por tracks nativos são uma próxima etapa com os IDs corretos; não dependem de refazer manualmente cada preload.

## Instalação e verificação

Sincronize o código e execute `tools/vfx-generators/07_ClientMotionAndSkills.luau` em Edit Mode, depois salve o place. O instalador move os assets existentes sem apagar as fontes e cria os clips/VFX das duas skills novas. Execute também nos outros places que compartilham Common.

O harness `tools/verify_client_motion_skills.luau` testa módulos reais com rigs e serviços simulados, sem salvar dados. Play ainda deve conferir chão inclinado, salto, visibilidade dos golpes entre dois clientes, respawn, streaming e aparência das novas skills.
