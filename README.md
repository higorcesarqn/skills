# skills

Minhas skills do Claude Code, para instalar em qualquer máquina.

| Skill | O que faz |
|---|---|
| `specify` | Especifica um item novo (issue do GitHub ou PBI do Azure DevOps) com grill-with-docs → to-spec → to-tickets e registra as etapas no painel-maestro |
| `implement-issue` | Implementa uma issue do GitHub e suas sub-issues num PR, um Worker por sub-issue; escolhe o fluxo (subagentes, floors do Maestri ou worktrees do Orca) pelo ambiente |
| `implement-pbi` | Implementa um PBI do Azure DevOps inteiro num PR, um Worker por task, com a mesma escolha de fluxo |
| `maestro-worker` | Protocolo do Worker num terminal visível (floor do Maestri ou worktree do Orca): implementa a task e reporta ao maestro |
| `atdd-spec` | Especificações ATDD/Gherkin para PBIs do Azure DevOps e validação funcional em HML |

A fonte de `specify`, `implement-*`, `maestro-worker` e dos docs `orchestration-*` é o [painel-maestro](https://github.com/higorcesarqn/painel-maestro) (pasta `skills/`). Aqui fica uma cópia. Essas skills chamam o CLI `flow` do painel-maestro, então ele precisa estar clonado na máquina, com `$PAINEL_MAESTRO` apontando para ele.

## Instalação

```bash
gh repo clone higorcesarqn/skills
cd skills
```

Windows (PowerShell). Se o Windows bloquear o script por política de execução, rode `powershell -ExecutionPolicy Bypass -File install.ps1`:

```powershell
./install.ps1                    # todas as skills
./install.ps1 implement-pbi      # só algumas
./install.ps1 -Link              # link simbólico: um git pull já atualiza as skills
./install.ps1 -NoPlugins         # pula a instalação dos plugins
```

Linux / macOS / Git Bash:

```bash
./install.sh
./install.sh implement-pbi
./install.sh --link
./install.sh --no-plugins
```

O que é instalado, sempre em `~/.claude` (ou em `$CLAUDE_CONFIG_DIR`, se essa variável estiver definida):

- `skills/<nome>` → `~/.claude/skills/<nome>`
- `docs/*` → `~/.claude/docs/`: os fluxos de orquestração (`orchestration-subagents`, `orchestration-maestri`, `orchestration-orca`) que as skills `implement-*` mandam seguir
- os plugins de `plugins.txt`

Se já existir algo com o mesmo nome no destino, é substituído. Se for um link (por exemplo, um que o `install-skills.js` do painel-maestro criou), só o link sai; a pasta para onde ele aponta fica intacta.

Numa máquina com o painel-maestro, prefira o instalador dele (`node bin/install-skills.js`) para essas skills: ele liga `~/.claude` à versão do painel. Rodar os scripts daqui depois troca esses links pela cópia deste repositório.

No Windows, `-Link` / `--link` precisa do Modo de Desenvolvedor ligado ou de um terminal como administrador.

Num PC logado na mesma conta claude.ai, a `atdd-spec` já chega sincronizada pela conta. Nesse caso, instale só as outras skills, para não ficar com duas cópias.

## Dependências

### Plugins (instalados pelos scripts)

Os scripts também instalam os plugins listados em [`plugins.txt`](plugins.txt), usando `claude plugin install`. Para isso, o CLI `claude` precisa estar no PATH.

- [mattpocock-skills](https://github.com/mattpocock/skills), do marketplace oficial da Anthropic. As skills de orquestração usam o `/implement`, o `/code-review`, o `/to-spec` e o `/to-tickets` dele. Para instalar manualmente:

  ```
  claude plugin install mattpocock-skills@claude-plugins-official
  ```

  Se o marketplace não estiver configurado, rode antes `claude plugin marketplace add anthropics/claude-plugins-official`.

Para adicionar outro plugin, coloque uma linha `<plugin>@<marketplace> <repositório-do-marketplace>` em `plugins.txt`.

### Ferramentas

- `specify`, `implement-*` e `maestro-worker`: o [painel-maestro](https://github.com/higorcesarqn/painel-maestro) (CLI `flow`, Node 22.13+), `bash` para os scripts em `docs/orchestration-*/scripts`
- fluxo do Maestri: app Maestri e as skills `maestri*` que ele instala; fluxo do Orca: CLI `orca`
- `implement-issue`: `gh` autenticado
- `implement-pbi` e `atdd-spec`: acesso ao Azure DevOps (`az` autenticado)
