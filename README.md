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
gh repo clone higorcesarqn/skills
cd skills
```

Windows (PowerShell). Se o Windows bloquear o script por política de execução, rode `powershell -ExecutionPolicy Bypass -File install.ps1`:

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

O que é instalado, sempre em `~/.claude` (ou em `$CLAUDE_CONFIG_DIR`, se essa variável estiver definida):

- `skills/<nome>` → `~/.claude/skills/<nome>`
- `docs/*` → `~/.claude/docs/`: o fluxo de orquestração que as skills `implementar-*` mandam seguir
- os plugins de `plugins.txt`

Se já existir algo com o mesmo nome no destino, é substituído.

No Windows, `-Link` / `--link` precisa do Modo de Desenvolvedor ligado ou de um terminal como administrador.

Num PC logado na mesma conta claude.ai, a `especificacao-atdd-hml` já chega sincronizada pela conta. Nesse caso, instale só as outras skills, para não ficar com duas cópias.

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

- `*-maestri` e `trabalhador-floor`: app Maestri e as skills `maestri*` que ele instala; `bash` e `python` para os scripts em `docs/orquestracao-maestri/scripts`
- `implementar-issue*`: `gh` autenticado
- `implementar-pbi*` e `especificacao-atdd-hml`: `az` autenticado com acesso ao Azure DevOps
