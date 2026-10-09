---
name: implementar-issue
description: "Implementa uma issue do GitHub e suas sub-issues num PR, com um subagente em worktree por sub-issue."
disable-model-invocation: true
---

O usuário passou o número de uma issue pai do GitHub. Siga o fluxo em `~/.claude/docs/orquestracao-subagentes.md`, usando este arquivo como **adaptador do tracker**. Tipo na branch: `issue` (ex.: `feature/issue-10`). As "tasks" do fluxo são as sub-issues.

## Adaptador GitHub

Use a CLI `gh`, no repo atual (`gh repo view --json nameWithOwner` dá `{owner}/{repo}`).

- **Item pai e tasks**: `gh issue view <n> --json number,title,body,state` e `gh api repos/{owner}/{repo}/issues/<n>/sub_issues --paginate`. Sem sub-issues nativas, use a task list do corpo da issue pai (`- [ ] #<n>`).
- **Arestas de bloqueio**: `gh api repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by` para cada sub-issue. Complemente com linhas `Blocked by #<n>` / `Bloqueada por #<n>` no corpo.
- **Estado**: task fechada é issue com `state: CLOSED`.
- **Abrir PR em rascunho**: `gh pr create --draft --base <origem> --head <integradora> --title "#<n> — <título>" --body "..."`, com uma linha `Closes #<x>` para a issue pai e para cada sub-issue.
- **Marcar task concluída**: o `Closes` fecha as issues no merge do PR; durante a execução, comente na sub-issue `gh issue comment <x> --body "Integrada em <integradora> (<sha>)"`.
- **Finalizar PR**: `gh pr ready <pr>`.
