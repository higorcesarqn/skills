# skills

Minhas skills do Claude Code, para instalar em qualquer máquina.

| Skill | O que faz |
|---|---|
| `implementar-issue` | Implementa uma issue do GitHub e suas sub-issues num PR, com um subagente em worktree por sub-issue |
| `implementar-issue-maestri` | Igual, mas com um floor do Maestri e um terminal Claude Code por sub-issue (rodar como maestro no Ground) |
| `implementar-pbi` | Implementa um PBI do Azure DevOps inteiro num PR, com um subagente em worktree por task |
| `implementar-pbi-maestri` | Igual, mas com um floor do Maestri por task (rodar como maestro no Ground) |
| `trabalhador-floor` | Protocolo do trabalhador num floor do Maestri: implementa a task e reporta ao maestro |
| `especificacao-atdd-hml` | Especificações ATDD/Gherkin para PBIs do Azure DevOps e validação funcional em HML |

## Instalação

```bash
git clone <url-deste-repo> skills
cd skills
```

Windows (PowerShell):

```powershell
./install.ps1                    # todas as skills
./install.ps1 implementar-pbi    # só algumas
./install.ps1 -Link              # link simbólico: um git pull já atualiza as skills
./install.ps1 -NoPlugins         # pula a instalação dos plugins
```

Linux / macOS / Git Bash:

```bash
./install.sh
./install.sh implementar-pbi
./install.sh --link
./install.sh --no-plugins
```

As skills vão para `~/.claude/skills/<nome>`. Se já existir uma skill com o mesmo nome lá, ela é substituída.

No Windows, `-Link` precisa do Modo de Desenvolvedor ligado ou de um terminal como administrador.

## Dependências

### Plugins (instalados pelos scripts)

Os scripts também instalam os plugins listados em [`plugins.txt`](plugins.txt), usando `claude plugin install`. Para isso, o CLI `claude` precisa estar no PATH.

- [mattpocock-skills](https://github.com/mattpocock/skills), do marketplace oficial da Anthropic. Para instalar manualmente:

  ```
  claude plugin install mattpocock-skills@claude-plugins-official
  ```

  Se o marketplace não estiver configurado, rode antes `claude plugin marketplace add anthropics/claude-plugins-official`.

Para adicionar outro plugin, coloque uma linha `<plugin>@<marketplace> <repositório-do-marketplace>` em `plugins.txt`.

### Ferramentas

- `*-maestri` e `trabalhador-floor`: app Maestri e as skills `maestri*` que ele instala
- `implementar-issue*`: `gh` autenticado
- `implementar-pbi*` e `especificacao-atdd-hml`: `az` autenticado com acesso ao Azure DevOps
