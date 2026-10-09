# Instala as skills e os docs deste repositório no diretório do Claude Code
# ($env:CLAUDE_CONFIG_DIR, ou ~/.claude) e os plugins de plugins.txt.
# Uso:
#   ./install.ps1                       # instala todas as skills
#   ./install.ps1 implementar-pbi ...   # instala só as indicadas
#   ./install.ps1 -Link                 # cria links simbólicos em vez de copiar (git pull atualiza)
#   ./install.ps1 -NoPlugins            # não instala os plugins de plugins.txt
param(
    [switch]$Link,
    [switch]$NoPlugins,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Names
)

$ErrorActionPreference = 'Stop'
$claudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }

function Install-Entry([string]$from, [string]$to) {
    New-Item -ItemType Directory -Force (Split-Path $to) | Out-Null
    if (Test-Path $to) { Remove-Item -Recurse -Force $to }
    if ($Link) {
        New-Item -ItemType SymbolicLink -Path $to -Target $from | Out-Null
    } else {
        Copy-Item -Recurse $from $to
    }
    Write-Host "ok  $to"
}

# Skills
$skillsSource = Join-Path $PSScriptRoot 'skills'
if (-not $Names) { $Names = (Get-ChildItem $skillsSource -Directory).Name }
foreach ($name in $Names) {
    $from = Join-Path $skillsSource $name
    if (-not (Test-Path (Join-Path $from 'SKILL.md'))) {
        Write-Warning "Skill '$name' não existe em $skillsSource"
        continue
    }
    Install-Entry $from (Join-Path $claudeDir "skills/$name")
}

# Docs de orquestração lidos pelas skills implementar-*
foreach ($entry in Get-ChildItem (Join-Path $PSScriptRoot 'docs')) {
    Install-Entry $entry.FullName (Join-Path $claudeDir "docs/$($entry.Name)")
}

# Plugins
if ($NoPlugins) { return }
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Warning "CLI 'claude' não encontrado; instale os plugins de plugins.txt manualmente"
    return
}

$ErrorActionPreference = 'Continue'
$marketplaces = (claude plugin marketplace list 2>&1) -join "`n"
foreach ($line in Get-Content (Join-Path $PSScriptRoot 'plugins.txt')) {
    if ($line -match '^\s*(#|$)') { continue }
    $plugin, $repo = $line.Trim() -split '\s+'
    $marketplace = ($plugin -split '@')[1]
    if ($repo -and $marketplaces -notmatch "\b$([regex]::Escape($marketplace))\b") {
        claude plugin marketplace add $repo
    }
    claude plugin install $plugin
    if ($LASTEXITCODE -eq 0) { Write-Host "ok  plugin $plugin" } else { Write-Warning "Falha ao instalar o plugin $plugin" }
}
