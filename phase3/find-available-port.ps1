param(
    [int]$StartPort = 3002,
    [int]$Range = 10,
    [string]$ComposeFile = "docker-compose.yml"
)

<#
.SYNOPSIS
Finds an available port in a range and updates docker-compose.yml for OpenHands.

.DESCRIPTION
This script tests ports sequentially, finds the first available port in the specified range,
updates docker-compose.yml with the new port mapping, and restarts the OpenHands container.

.PARAMETER StartPort
The first port to test (default: 3002 for Phase 3, to avoid conflict with Phase 2 on 3001)

.PARAMETER Range
Number of ports to test in the range (default: 10, so 3002-3011)

.PARAMETER ComposeFile
Path to docker-compose.yml (default: current directory)

.EXAMPLE
# Find available port in range 3002-3011
.\find-available-port.ps1

# Find available port in range 4000-4009
.\find-available-port.ps1 -StartPort 4000 -Range 10
#>

function Test-PortAvailable {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("127.0.0.1", $Port)
        $connection.Close()
        return $false  # Port is in use
    }
    catch {
        return $true   # Port is available
    }
}

# Validate compose file exists
$composePath = Join-Path (Get-Location) $ComposeFile
if (-not (Test-Path $composePath)) {
    Write-Host "❌ Erreur : $ComposeFile introuvable dans $(Get-Location)" -ForegroundColor Red
    exit 1
}

Write-Host "🔍 Recherche d'un port disponible dans la plage $StartPort-$($StartPort + $Range - 1)..." -ForegroundColor Cyan

# Find first available port
$availablePort = $null
for ($i = 0; $i -lt $Range; $i++) {
    $testPort = $StartPort + $i
    if (Test-PortAvailable -Port $testPort) {
        $availablePort = $testPort
        Write-Host "✅ Port disponible trouvé : $availablePort" -ForegroundColor Green
        break
    }
    else {
        Write-Host "  ❌ Port $testPort occupé" -ForegroundColor DarkGray
    }
}

if (-not $availablePort) {
    Write-Host "❌ Aucun port disponible dans la plage $StartPort-$($StartPort + $Range - 1)" -ForegroundColor Red
    exit 1
}

# Update docker-compose.yml
Write-Host "📝 Mise à jour de $ComposeFile..." -ForegroundColor Cyan
$content = Get-Content $composePath -Raw
$newContent = $content -replace '- "(\d+):3000"', "- ""$availablePort`:3000"""
Set-Content $composePath $newContent -Encoding UTF8

# Restart container
Write-Host "🔄 Redémarrage du conteneur OpenHands..." -ForegroundColor Cyan
docker compose down 2>&1 | Out-Null
docker compose up -d 2>&1 | Out-Null

Write-Host ""
Write-Host "✨ OpenHands sera accessible sur : http://localhost:$availablePort" -ForegroundColor Green
Write-Host ""
