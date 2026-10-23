#!/usr/bin/env bash
# Instala as skills e os docs deste repositório no diretório do Claude Code
# ($CLAUDE_CONFIG_DIR, ou ~/.claude) e os plugins de plugins.txt.
# Uso:
#   ./install.sh                       # instala todas as skills
#   ./install.sh implement-pbi ...     # instala só as indicadas
#   ./install.sh --link                # cria links simbólicos em vez de copiar (git pull atualiza)
#   ./install.sh --no-plugins          # não instala os plugins de plugins.txt
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
# No Git Bash, sem isto o ln -s copia em silêncio em vez de criar link
export MSYS=winsymlinks:nativestrict
link=false
plugins=true

while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --link) link=true ;;
    --no-plugins) plugins=false ;;
    *) echo "opção desconhecida: $1" >&2; exit 1 ;;
  esac
  shift
done

install_entry() {
  local from="$1" to="$2"
  mkdir -p "$(dirname "$to")"
  rm -rf "$to"
  if $link; then ln -s "$from" "$to"; else cp -r "$from" "$to"; fi
  echo "ok  $to"
}

# Skills
if [[ $# -eq 0 ]]; then
  set -- $(ls "$repo_dir/skills")
fi
for name in "$@"; do
  if [[ ! -f "$repo_dir/skills/$name/SKILL.md" ]]; then
    echo "aviso: skill '$name' não existe em $repo_dir/skills" >&2
    continue
  fi
  install_entry "$repo_dir/skills/$name" "$claude_dir/skills/$name"
done

# Docs de orquestração lidos pelas skills implement-*, specify e maestro-worker
for entry in "$repo_dir"/docs/*; do
  install_entry "$entry" "$claude_dir/docs/$(basename "$entry")"
done

# Plugins
$plugins || exit 0
if ! command -v claude >/dev/null; then
  echo "aviso: CLI 'claude' não encontrado; instale os plugins de plugins.txt manualmente" >&2
  exit 0
fi

marketplaces="$(claude plugin marketplace list 2>&1 || true)"
while read -r plugin repo; do
  [[ -z "$plugin" || "$plugin" == \#* ]] && continue
  marketplace="${plugin#*@}"
  if [[ -n "$repo" ]] && ! grep -qw -- "$marketplace" <<<"$marketplaces"; then
    claude plugin marketplace add "$repo" || true
  fi
  if claude plugin install "$plugin"; then
    echo "ok  plugin $plugin"
  else
    echo "aviso: falha ao instalar o plugin $plugin" >&2
  fi
done < "$repo_dir/plugins.txt"
