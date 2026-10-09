# Instala as skills deste repositório em ~/.claude/skills.
# Uso:
#   ./install.ps1                       # instala todas
#   ./install.ps1 implementar-pbi ...   # instala só as indicadas
#   ./install.ps1 -Link                 # cria links simbólicos em vez de copiar (git pull atualiza)
#   ./install.ps1 -NoPlugins            # não instala os plugins de plugins.txt
param(
    [switch]$Link,
    [switch]$NoPlugins,
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

if ($NoPlugins) { return }
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Warning "CLI 'claude' não encontrado; instale os plugins de plugins.txt manualmente"
    return
}

$ErrorActionPreference = 'Continue'
$marketplaces = (claude plugin marketplace list 2>&1) -join "`n"
foreach ($line in Get-Content (Join-Path $PSScriptRoot 'plugins.txt')) {
    if ($line -match '^\s*(#|$)') { continue }
    $plugin, $repo = $line -split '\s+'
    $marketplace = ($plugin -split '@')[1]
    if ($repo -and $marketplaces -notmatch "\b$([regex]::Escape($marketplace))\b") {
        claude plugin marketplace add $repo
    }
    claude plugin install $plugin
    if ($LASTEXITCODE -eq 0) { Write-Host "ok  plugin $plugin" } else { Write-Warning "Falha ao instalar o plugin $plugin" }
}
