# Orquestração de subagentes por task

Fluxo compartilhado por `/implementar-pbi` (Azure DevOps) e `/implementar-issue` (GitHub). A skill que apontou para cá fornece o **adaptador do tracker**: como ler o item pai e as tasks, como achar os bloqueios, como abrir e finalizar o PR. Tudo abaixo é agnóstico de tracker.

O objetivo é **um único PR** que implementa o item pai inteiro, numa única **branch integradora**.

## Vocabulário

- **Grafo de tasks**: as tasks não são uma lista de passos, são nós com arestas de bloqueio (`A bloqueia B`).
- **Fronteira**: as tasks abertas cujos bloqueadores já foram integrados. Só a fronteira pode ser despachada.
- **Branch integradora**: a branch do PR, criada a partir da **branch de origem** (a branch em que o usuário estava ao invocar a skill).
- **Ponteiros de contexto**: IDs de itens, caminhos de notas, SHAs de commit. A comunicação com subagentes é esparsa e feita por ponteiros; o subagente lê o item no tracker em vez de receber o texto copiado.

## Passos

1. **Ler o grafo.** Pelo adaptador, carregue o item pai, as tasks filhas e as arestas de bloqueio. Leia `docs/agents/` do repositório, se existir, para convenções locais (nome de branch, comandos de typecheck/teste, estados do tracker). Pronto quando: cada task tem estado (aberta/fechada) e lista de bloqueadores conhecidos. Task sem aresta declarada é independente; se duas tasks independentes claramente tocam o mesmo fluxo, pergunte ao usuário antes de paralelizar.

2. **Explorar (opcional).** Se as tasks exigem entender código ou documentação externa, despache um **subagente explorador** que salva notas markdown no scratchpad da sessão (fora do repo). Os implementadores recebem o caminho dessas notas como ponteiro.

3. **Preparar a branch integradora.** A partir da branch de origem, crie a branch integradora (padrão `feature/<tipo>-<id>` salvo convenção local), faça push e abra o PR em **rascunho** pelo adaptador, vinculado ao item pai e a todas as tasks. Deixe a branch integradora em checkout no diretório principal: é dela que as worktrees partem e é nela que os merges acontecem.

4. **Despachar a fronteira.** Para cada task da fronteira, um **subagente implementador** via Agent tool com `isolation: "worktree"` e `run_in_background: true`. Concorrência máxima: 3 simultâneos, salvo pedido do usuário. O prompt do implementador leva só ponteiros e o contrato abaixo.

   Contrato do implementador:
   - Criar a branch `task/<id>` na worktree, a partir do HEAD atual da branch integradora.
   - Instalar dependências na worktree com o comando do lockfile do repo (`npm ci`, `pnpm i --frozen-lockfile`, ...).
   - Ler a task `<id>` no tracker e as notas do explorador, se houver.
   - Implementar com a skill `mattpocock-skills:tdd` nas seams combinadas; rodar typecheck e os testes dos arquivos tocados.
   - Commitar na `task/<id>` com mensagem referenciando a task.
   - Responder apenas: nome da branch, SHA final, status (`ok` | `bloqueado: <motivo>`), e riscos de conflito (arquivos compartilhados tocados: rotas, registro de reducers/sagas, menus, configs).

5. **Integrar cada conclusão.** Quando um implementador responder `ok`, despache um **subagente de merge** (foreground, um por vez; merges nunca rodam em paralelo) que faz `git merge --no-ff task/<id>` na branch integradora, resolve conflitos com a skill `mattpocock-skills:resolving-merge-conflicts`, roda typecheck e faz push. Depois, marque a task como concluída pelo adaptador. Implementador `bloqueado` volta para o usuário com o motivo.

6. **Recalcular a fronteira.** Após cada integração, tasks recém-desbloqueadas entram na fronteira: despache-as (passo 4). Repita 4–6 até todas as tasks estarem integradas. Pronto quando: toda task do grafo está integrada ou foi reportada como bloqueada ao usuário.

7. **Revisar.** Rode a suíte completa de testes. Depois, na branch integradora contra a branch de origem, rode as duas revisões em sequência:
   1. Skill `mattpocock-skills:code-review`: Standards + Spec, confere o diff contra os padrões do repo e contra cada task.
   2. Skill `code-review` (nativa do Claude Code) no nível `medium`: bugs de corretude, reuso e simplificação. Pegadinhas típicas deste fluxo: helpers duplicados entre tasks e conflitos resolvidos para o lado errado no merge.

   Consolide os achados numa única lista. **Desempate**: quando um achado de simplificação contradiz um padrão do repo ou a spec, vence o padrão/spec. Despache **um único** implementador (sem worktree, na branch integradora) com essa lista para corrigir tudo, rode typecheck e testes, e faça push.

8. **Finalizar.** Tire o PR do rascunho pelo adaptador.

9. **Limpar.** Remova todas as worktrees e branches `task/*` locais criadas nesta execução (`git worktree list` para conferir; `git worktree prune`). Reporte ao usuário: link do PR, tasks integradas, tasks bloqueadas.
