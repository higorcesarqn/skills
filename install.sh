#!/usr/bin/env bash
# Instala as skills deste repositório em ~/.claude/skills.
# Uso:
#   ./install.sh                       # instala todas
#   ./install.sh implementar-pbi ...   # instala só as indicadas
#   ./install.sh --link                # cria links simbólicos em vez de copiar (git pull atualiza)
#   ./install.sh --no-plugins          # não instala os plugins de plugins.txt
set -euo pipefail

source_dir="$(cd "$(dirname "$0")" && pwd)/skills"
target_dir="$HOME/.claude/skills"
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
mkdir -p "$target_dir"

if [[ $# -eq 0 ]]; then
  set -- $(ls "$source_dir")
fi

for name in "$@"; do
  from="$source_dir/$name"
  if [[ ! -f "$from/SKILL.md" ]]; then
    echo "aviso: skill '$name' não existe em $source_dir" >&2
    continue
  fi
  to="$target_dir/$name"
  rm -rf "$to"
  if $link; then ln -s "$from" "$to"; else cp -r "$from" "$to"; fi
  echo "ok  $name -> $to"
done

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
done < "$(dirname "$0")/plugins.txt"
