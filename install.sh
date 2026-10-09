#!/usr/bin/env bash
# Instala as skills deste repositório em ~/.claude/skills.
# Uso:
#   ./install.sh                       # instala todas
#   ./install.sh implementar-pbi ...   # instala só as indicadas
#   ./install.sh --link                # cria links simbólicos em vez de copiar (git pull atualiza)
set -euo pipefail

source_dir="$(cd "$(dirname "$0")" && pwd)/skills"
target_dir="$HOME/.claude/skills"
link=false

if [[ "${1:-}" == "--link" ]]; then link=true; shift; fi
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
