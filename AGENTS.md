# AGENTS.md

Repositório pessoal de skills do Claude Code. Não tem build, dependências nem testes. Cada skill é uma pasta `skills/<nome>/` com um `SKILL.md`. Os scripts de instalação copiam `skills/*` para `~/.claude/skills/` e `docs/*` para `~/.claude/docs/`, ou para dentro de `$CLAUDE_CONFIG_DIR` quando essa variável está definida.

## Estrutura

- `skills/<nome>/SKILL.md`: o `name` do frontmatter tem que ser igual ao nome da pasta. Os scripts identificam uma skill pela existência desse arquivo.
- `docs/`: os fluxos de orquestração (`orchestration-subagents`, `orchestration-maestri`, `orchestration-orca`, com os scripts deles) que as skills `implement-*` mandam seguir. As skills e os próprios docs apontam para esses arquivos pelo caminho instalado (`~/.claude/docs/...`). Se você mudar o caminho de algum, atualize as referências.
- `install.ps1` / `install.sh`: fazem a mesma coisa e precisam continuar equivalentes. Qualquer opção nova vai nos dois e no README. O `install.ps1` precisa continuar rodando no Windows PowerShell 5.1: nada de `??` ou ternário, e o arquivo fica em UTF-8 **com BOM** para os acentos saírem certos. O `install.sh` exporta `MSYS=winsymlinks:nativestrict`, porque sem isso o `--link` copia em silêncio no Git Bash. Quando o destino já é um link (o `install-skills.js` do painel-maestro cria links), o `install.ps1` apaga só o link: no PowerShell 5.1, `Remove-Item -Recurse` num link de pasta pode apagar o conteúdo do destino.
- `plugins.txt`: plugins de que as skills dependem, instalados pelos scripts via `claude plugin install`. Formato de cada linha: `<plugin>@<marketplace> <repo-github-do-marketplace>`. O repo serve para rodar `claude plugin marketplace add` quando o marketplace não estiver configurado.
- `.gitattributes`: força LF em `*.sh` e `plugins.txt`. Sem isso, o checkout no Windows grava CRLF e o `install.sh` quebra no Git Bash. Todo arquivo novo que o `install.sh` for ler precisa entrar ali.

## Skills e suas dependências

`specify`, `implement-issue`, `implement-pbi`, `maestro-worker` e os docs `orchestration-*` são **cópias**. A fonte é o repositório `painel-maestro` (pasta `skills/`, mapeada no `skills/links.json` de lá), que também fornece o CLI `flow` que elas chamam (`node "$PAINEL_MAESTRO/bin/flow.js"`). Mude o fluxo lá e traga a mudança para cá; edições feitas só aqui se perdem na próxima cópia. Para sincronizar, copie `painel-maestro/skills/<skill>` para `skills/<skill>` e `painel-maestro/skills/docs/<doc>` para `docs/<doc>`. O `links.json` não vem. Os nomes antigos em português (`implementar-*`, `trabalhador-floor`, `docs/orquestracao-*`) foram aposentados lá e não voltam.

As skills de orquestração são em inglês (contrato lido por agente), mas falam com o dono e gravam no painel em português. Elas dependem do plugin `mattpocock-skills`: usam o `/implement`, o `/code-review`, o `/to-spec` e o `/to-tickets` dele. O instalador do painel-maestro não instala plugins, por isso o `plugins.txt` daqui cuida disso.

A `atdd-spec` (antiga `especificacao-atdd-hml`) é independente das outras. A fonte original está na conta claude.ai do autor (sincronizada em `~/.claude/skills/synced/`). Edições feitas aqui não voltam para lá sozinhas: troque a skill no claude.ai também (Customize > Skills).

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

Use sempre `--no-plugins` / `-NoPlugins` nesse teste. O CLI `claude` também lê `CLAUDE_CONFIG_DIR` e baixaria os plugins na pasta temporária. Para testar a parte dos plugins, rode sem a variável: com o plugin já instalado, a resposta esperada é "already installed". Na máquina do autor, não instale a `atdd-spec` em `~/.claude/skills`, porque ela duplicaria a versão sincronizada pela conta, nem rode o script sem `CLAUDE_CONFIG_DIR` temporário: ele trocaria os links do painel-maestro por cópias.
