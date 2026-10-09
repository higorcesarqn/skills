---
name: implementar-pbi
description: "Implementa um PBI do Azure DevOps inteiro num PR, com um subagente em worktree por task."
disable-model-invocation: true
---

O usuário passou o ID de um PBI do Azure DevOps. Siga o fluxo em `~/.claude/docs/orquestracao-subagentes.md`, usando este arquivo como **adaptador do tracker**. Tipo na branch: `pbi` (ex.: `feature/pbi-10`).

## Adaptador Azure DevOps

Use a CLI `az` com a extensão `azure-devops`. Organização e projeto vêm de `docs/agents/` do repo ou de `az devops configure --list`; se nenhum estiver definido, pergunte ao usuário e configure com `az devops configure --defaults organization=... project=...`.

- **Item pai e tasks**: `az boards work-item show --id <pbi> --expand relations`. Tasks filhas são as relações `System.LinkTypes.Hierarchy-Forward`; carregue cada uma com `az boards work-item show --id <task> --expand relations`.
- **Arestas de bloqueio**: numa task, a relação `System.LinkTypes.Dependency-Reverse` (Predecessor) aponta para quem a bloqueia. Complemente com linhas `Bloqueada por: #<id>` na descrição (`System.Description`).
- **Estado**: task fechada é a que está em estado da categoria Completed (`Done`, `Closed`...). Leia os estados válidos em `docs/agents/` ou com `az boards work-item show` num item já concluído.
- **Abrir PR em rascunho**: `az repos pr create --draft true --source-branch <integradora> --target-branch <origem> --title "PBI <id> — <título>" --work-items <pbi> <tasks...> --description "..."`.
- **Marcar task concluída**: `az boards work-item update --id <task> --state <estado concluído>`.
- **Finalizar PR**: `az repos pr update --id <pr> --draft false`.
