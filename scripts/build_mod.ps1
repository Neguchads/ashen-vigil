# Empacota mods/<Mod> em build/mods/<Mod>/. Com -Install, copia para a pasta de mods do jogo.
param(
    [Parameter(Mandatory)] [ValidatePattern('^[a-z0-9_]+$')] [string]$Mod,
    [switch]$Install
)
$ErrorActionPreference = 'Stop'
if ($Mod -eq 'core') { throw "O id 'core' é reservado ao jogo base." }
$root = Split-Path -Parent $PSScriptRoot
$godot = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { 'A:\AI\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' }
$src = Join-Path $root "mods\$Mod"
$out = Join-Path $root 'build\mods'
if (-not (Test-Path -LiteralPath $godot)) { throw "Godot não encontrado em $godot. Defina GODOT_BIN." }
if (-not (Test-Path (Join-Path $src 'mod.json'))) { Write-Host "Mod não encontrado: $src" -ForegroundColor Red; exit 1 }

# O Godot espera barras normais nos caminhos.
& $godot --headless --path (Join-Path $root 'game') -s res://tools/build_mod.gd -- $src.Replace('\', '/') $out.Replace('\', '/')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($Install) {
    $dest = Join-Path $env:APPDATA "Godot\app_userdata\Ashen Vigil\mods\$Mod"
    New-Item -ItemType Directory -Force $dest | Out-Null
    foreach ($name in @('mod.json', "$Mod.pck")) {
        Copy-Item -LiteralPath (Join-Path $out "$Mod\$name") -Destination $dest -Force
    }
    Write-Host "Instalado em $dest"
}
