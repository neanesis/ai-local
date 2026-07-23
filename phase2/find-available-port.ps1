# Script pour trouver le premier port disponible et configurer Open WebUI
# Usage: .\find-available-port.ps1 -StartPort 3000 -Range 10

param(
    [int]$StartPort = 3000,
    [int]$Range = 10,
    [string]$EnvFile = ".env"
)

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

Write-Host "Recherche du premier port disponible à partir de $StartPort..." -ForegroundColor Cyan

$availablePort = $null
for ($i = 0; $i -lt $Range; $i++) {
    $testPort = $StartPort + $i
    if (Test-PortAvailable -Port $testPort) {
        $availablePort = $testPort
        Write-Host "✓ Port disponible trouvé : $availablePort" -ForegroundColor Green
        break
    }
    else {
        Write-Host "  Port $testPort occupé" -ForegroundColor DarkGray
    }
}

if (-not $availablePort) {
    Write-Host "✗ Aucun port disponible dans la plage $StartPort-$($StartPort + $Range - 1)" -ForegroundColor Red
    exit 1
}

# Mettre à jour docker-compose.yml avec le port trouvé
$dockerComposePath = "docker-compose.yml"
$dockerComposeContent = Get-Content $dockerComposePath -Raw

# Remplacer le port dans la config (pattern: ports: avec - "3000:8080")
$newContent = $dockerComposeContent -replace '- "(\d+):8080"', "- ""$availablePort`:8080"""

if ($newContent -ne $dockerComposeContent) {
    Set-Content $dockerComposePath $newContent -Encoding UTF8
    Write-Host "✓ docker-compose.yml mis à jour : port $availablePort" -ForegroundColor Green
}

# Afficher le résumé
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Open WebUI sera accessible sur :" -ForegroundColor Cyan
Write-Host "  http://localhost:$availablePort" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Lancer docker compose
Write-Host ""
Write-Host "Démarrage de Open WebUI..." -ForegroundColor Cyan
docker compose down 2>&1 | Out-Null
docker compose up -d
docker compose ps
