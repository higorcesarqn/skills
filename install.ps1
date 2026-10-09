# Instala as skills deste repositório em ~/.claude/skills.
# Uso:
#   ./install.ps1                       # instala todas
#   ./install.ps1 implementar-pbi ...   # instala só as indicadas
#   ./install.ps1 -Link                 # cria links simbólicos em vez de copiar (git pull atualiza)
param(
    [switch]$Link,
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Names
)

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'skills'
$target = Join-Path $HOME '.claude/skills'
New-Item -ItemType Directory -Force $target | Out-Null

if (-not $Names) { $Names = (Get-ChildItem $source -Directory).Name }

foreach ($name in $Names) {
    $from = Join-Path $source $name
    if (-not (Test-Path (Join-Path $from 'SKILL.md'))) {
        Write-Warning "Skill '$name' não existe em $source"
        continue
    }
    $to = Join-Path $target $name
    if (Test-Path $to) { Remove-Item -Recurse -Force $to }
    if ($Link) {
        New-Item -ItemType SymbolicLink -Path $to -Target $from | Out-Null
    } else {
        Copy-Item -Recurse $from $to
    }
    Write-Host "ok  $name -> $to"
}
