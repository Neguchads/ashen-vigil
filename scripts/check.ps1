# Roda formatação, lint, varredura de segredos e testes. Sai com 0 só se tudo passar.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$game = Join-Path $root 'game'
$godot = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { 'A:\AI\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' }
$venv = Join-Path $root '.venv\Scripts'

function Fail([string]$msg, [int]$code = 1) {
    Write-Host "FALHOU: $msg" -ForegroundColor Red
    exit $code
}

if (-not (Test-Path $godot)) { Fail "Godot não encontrado em $godot. Defina GODOT_BIN." }
if (-not (Test-Path (Join-Path $venv 'gdformat.exe'))) { Fail 'gdtoolkit ausente. Rode: py -3.12 -m venv .venv; .\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt' }

# @(...) garante lista mesmo com uma pasta só; senão o splat recebe texto solto.
$code_dirs = @(@('src', 'tests', 'tools') | ForEach-Object { Join-Path $game $_ } | Where-Object { Test-Path $_ })

Write-Host '== gdformat --check'
& (Join-Path $venv 'gdformat.exe') --check @code_dirs
if ($LASTEXITCODE -ne 0) { Fail 'formatação. Rode .\.venv\Scripts\gdformat.exe game\src game\tests game\tools' }

Write-Host '== gdlint'
& (Join-Path $venv 'gdlint.exe') @code_dirs
if ($LASTEXITCODE -ne 0) { Fail 'lint' }

Write-Host '== segredos'
Push-Location $root
git grep -nIE '(BEGIN [A-Z ]*PRIVATE KEY|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,})' -- . ':!*.md'
$found = ($LASTEXITCODE -eq 0)
Pop-Location
if ($found) { Fail 'possível segredo no repositório (linhas acima)' }

Write-Host '== importação do projeto'
& $godot --headless --path $game --import
if ($LASTEXITCODE -ne 0) { Fail 'importação do Godot' $LASTEXITCODE }

Write-Host '== testes (GdUnit4)'
& $godot --headless --path $game -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests -c --ignoreHeadlessMode
if ($LASTEXITCODE -ne 0) { Fail "testes (código $LASTEXITCODE; 100 = falhas, 101 = avisos)" $LASTEXITCODE }

Write-Host 'OK: tudo passou' -ForegroundColor Green
