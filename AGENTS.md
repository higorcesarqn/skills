# AGENTS.md

Repositório pessoal de skills do Claude Code. Não tem build, dependências nem testes. Cada skill é uma pasta `skills/<nome>/` com um `SKILL.md`. Os scripts de instalação copiam `skills/*` para `~/.claude/skills/` e `docs/*` para `~/.claude/docs/`, ou para dentro de `$CLAUDE_CONFIG_DIR` quando essa variável está definida.

## Estrutura

- `skills/<nome>/SKILL.md`: o `name` do frontmatter tem que ser igual ao nome da pasta. Os scripts identificam uma skill pela existência desse arquivo.
- `docs/`: o fluxo de orquestração que as skills `implementar-*` mandam seguir. As skills e os próprios docs apontam para esses arquivos pelo caminho instalado (`~/.claude/docs/...`). Se você mudar o caminho de algum, atualize as referências.
- `install.ps1` / `install.sh`: fazem a mesma coisa e precisam continuar equivalentes. Qualquer opção nova vai nos dois e no README. O `install.ps1` precisa continuar rodando no Windows PowerShell 5.1: nada de `??` ou ternário, e o arquivo fica em UTF-8 **com BOM** para os acentos saírem certos. O `install.sh` exporta `MSYS=winsymlinks:nativestrict`, porque sem isso o `--link` copia em silêncio no Git Bash.
- `plugins.txt`: plugins de que as skills dependem, instalados pelos scripts via `claude plugin install`. Formato de cada linha: `<plugin>@<marketplace> <repo-github-do-marketplace>`. O repo serve para rodar `claude plugin marketplace add` quando o marketplace não estiver configurado.
- `.gitattributes`: força LF em `*.sh` e `plugins.txt`. Sem isso, o checkout no Windows grava CRLF e o `install.sh` quebra no Git Bash. Todo arquivo novo que o `install.sh` for ler precisa entrar ali.

## Skills e suas dependências

As skills estão em português e dependem do plugin `mattpocock-skills`: o fluxo dos trabalhadores usa as skills `/implement` e `/code-review` dele.

As skills `implementar-*` são apenas **adaptadores de tracker** (GitHub via `gh`, Azure DevOps via REST). O fluxo de orquestração em si fica em `docs/`:

- `implementar-issue`, `implementar-pbi`: seguem `docs/orquestracao-subagentes.md`, com subagentes em worktrees.
- `implementar-issue-maestri`, `implementar-pbi-maestri`: seguem `docs/orquestracao-maestri/README.md`, que usa os scripts `abrir-floor.sh`, `integrar.sh` e `fluxo.py` da pasta `scripts/` ao lado. O maestro roda essas skills no Ground e abre um floor por task. A `trabalhador-floor` é o protocolo que o terminal de cada floor segue.

Se uma mudança mexer no fluxo, ela vai nesses docs. Nas skills só entra o que for específico do tracker. Depois de mudar o fluxo do Maestri, confira se a `trabalhador-floor` continua batendo com ele.

A `especificacao-atdd-hml` é independente das outras. A fonte original está na conta claude.ai do autor (sincronizada em `~/.claude/skills/synced/`). Edições feitas aqui não voltam para lá sozinhas.

Nas skills do Azure DevOps, a leitura e a escrita usam a REST com `curl` e Python em UTF-8, nunca o `az boards`. No Windows, o `az` corrompe acentos. Mantenha isso ao editar essas skills.

## Adicionar ou atualizar uma skill

1. Copie a pasta de `~/.claude/skills/<nome>` para `skills/<nome>`.
2. Procure caminhos absolutos, nomes de organização ou projeto e tokens. URLs do Azure DevOps ficam como `https://dev.azure.com/<org>/<projeto>`.
3. Procure referências a arquivos fora da pasta da skill (`grep -rn '~/\.claude' skills docs`). Tudo o que a skill lê precisa estar no repositório: em `docs/`, se for compartilhado, ou dentro da pasta da skill. Skill ou plugin de terceiros vai para `plugins.txt`.
4. Acrescente a skill na tabela do README.

## Verificar os scripts

Aponte `CLAUDE_CONFIG_DIR` para uma pasta temporária. Assim a instalação real não é tocada:

```bash
bash -n install.sh
T=$(mktemp -d)
CLAUDE_CONFIG_DIR=$T ./install.sh --no-plugins && find $T -type f
CLAUDE_CONFIG_DIR=$(cygpath -w $T/ps) powershell -NoProfile -ExecutionPolicy Bypass -File ./install.ps1 -NoPlugins   # Windows PowerShell 5.1
rm -rf $T
```

Use sempre `--no-plugins` / `-NoPlugins` nesse teste. O CLI `claude` também lê `CLAUDE_CONFIG_DIR` e baixaria os plugins na pasta temporária. Para testar a parte dos plugins, rode sem a variável: com o plugin já instalado, a resposta esperada é "already installed". Na máquina do autor, não instale a `especificacao-atdd-hml` em `~/.claude/skills`, porque ela duplicaria a versão sincronizada pela conta.
