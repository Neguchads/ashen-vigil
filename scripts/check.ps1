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
git grep --untracked --exclude-standard -nIE '(BEGIN [A-Z ]*PRIVATE KEY|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,})' -- . ':!*.md'
$scan_exit = $LASTEXITCODE
Pop-Location
if ($scan_exit -eq 0) { Fail 'possível segredo no repositório (linhas acima)' }
if ($scan_exit -gt 1) { Fail 'não foi possível executar a varredura de segredos' }

# Mantém mods e configurações pessoais fora dos testes, inclusive na importação.
$previous_appdata = $env:APPDATA
try {
    $env:APPDATA = Join-Path $game '.godot/check-profile'
    New-Item -ItemType Directory -Force $env:APPDATA | Out-Null
    Write-Host '== importação do projeto'
    $import_log = Join-Path ([IO.Path]::GetTempPath()) ('ashen-vigil-import-' + [Guid]::NewGuid().ToString('N') + '.log')
    & $godot --headless --path $game --import > $import_log 2>&1
    $import_exit = $LASTEXITCODE
    Get-Content $import_log | Select-Object -Last 14
    if ($import_exit -ne 0) { Fail 'importação do Godot' $import_exit }
    if (Select-String -Path $import_log -Pattern 'ERROR:|SCRIPT ERROR|Parse Error' -Quiet) {
        Fail "Godot emitiu erro durante a importação; veja $import_log"
    }

    Write-Host '== testes (GdUnit4)'
    # Sem -d (modo debug): com ele, um erro de parse abre o depurador interativo e o Godot trava.
    # O tempo limite garante que um travamento vira falha, não espera infinita.
    $log = Join-Path ([IO.Path]::GetTempPath()) ('ashen-vigil-tests-' + [Guid]::NewGuid().ToString('N') + '.log')
    $args_test = @('--headless', '--path', "`"$game`"", '-s', 'res://addons/gdUnit4/bin/GdUnitCmdTool.gd', '-a', 'res://tests', '-c', '--ignoreHeadlessMode')
    $proc = Start-Process -FilePath $godot -ArgumentList $args_test -NoNewWindow -PassThru -RedirectStandardOutput $log -RedirectStandardError "$log.err"
    if (-not $proc.WaitForExit(300000)) {
        $proc.Kill($true)
        Get-Content $log -Tail 30
        Fail 'testes travaram (mais de 5 min); veja o log acima'
    }
    Get-Content $log | Select-String -Pattern 'STARTED' -NotMatch | Select-Object -Last 40
    Get-Content "$log.err" | Select-String -Pattern 'SCRIPT ERROR|Parse Error|Parser Error' | Select-Object -First 10
    if ($proc.ExitCode -ne 0) { Fail "testes (código $($proc.ExitCode); 100 = falhas, 101 = avisos)" $proc.ExitCode }

    Write-Host 'OK: tudo passou' -ForegroundColor Green
} finally {
    $env:APPDATA = $previous_appdata
}
