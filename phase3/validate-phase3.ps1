param(
    [string]$ProjectPath = (Get-Item (Split-Path $MyInvocation.MyCommand.Path)).Parent.FullName
)

$phase3Path = Split-Path $MyInvocation.MyCommand.Path
$checksPass = 0
$checksTotal = 0

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           Phase 3 — OpenHands Validation               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check 1: Docker Desktop running
$checksTotal++
Write-Host "Check 1/10: Docker Desktop running..." -NoNewline -ForegroundColor Gray
try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ PASS" -ForegroundColor Green
        $checksPass++
    }
    else {
        Write-Host " ❌ FAIL - Docker desktop not running" -ForegroundColor Red
    }
}
catch {
    Write-Host " ❌ FAIL - Docker not accessible" -ForegroundColor Red
}

# Check 2: OpenHands container exists
$checksTotal++
Write-Host "Check 2/10: OpenHands container exists..." -NoNewline -ForegroundColor Gray
$container = docker ps -a --filter "name=openhands" --format "{{.Names}}" 2>&1
if ($container -like "*openhands*") {
    Write-Host " ✅ PASS" -ForegroundColor Green
    $checksPass++
}
else {
    Write-Host " ❌ FAIL - Container not found" -ForegroundColor Red
}

# Check 3: OpenHands container running
$checksTotal++
Write-Host "Check 3/10: OpenHands container running..." -NoNewline -ForegroundColor Gray
$status = docker ps --filter "name=openhands" --format "{{.Status}}" 2>&1
if ($status -like "Up*") {
    Write-Host " ✅ PASS" -ForegroundColor Green
    $checksPass++
}
else {
    Write-Host " ❌ FAIL - Container not running (Status: $status)" -ForegroundColor Red
}

# Check 4: Port mapping configured
$checksTotal++
Write-Host "Check 4/10: Port mapping configured..." -NoNewline -ForegroundColor Gray
$ports = docker ps --filter "name=openhands" --format "{{.Ports}}" 2>&1
$portMatch = $ports -match "(\d+)->3000/tcp"
if ($portMatch) {
    $port = $matches[1]
    Write-Host " ✅ PASS (Port: $port)" -ForegroundColor Green
    $checksPass++
}
else {
    Write-Host " ❌ FAIL - No port mapping found" -ForegroundColor Red
}

# Check 5: .env file exists and configured
$checksTotal++
Write-Host "Check 5/10: .env file configured..." -NoNewline -ForegroundColor Gray
$envPath = Join-Path $phase3Path ".env"
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath
    if (($envContent | Select-String "OPENAI_API_KEY=" -Quiet) -and 
        ($envContent | Select-String "LLM_MODEL=" -Quiet)) {
        Write-Host " ✅ PASS" -ForegroundColor Green
        $checksPass++
    }
    else {
        Write-Host " ❌ FAIL - .env missing required variables" -ForegroundColor Red
    }
}
else {
    Write-Host " ❌ FAIL - .env file not found" -ForegroundColor Red
}

# Check 6: LM Studio API accessible
$checksTotal++
Write-Host "Check 6/10: LM Studio API accessible (localhost:1234)..." -NoNewline -ForegroundColor Gray
try {
    $response = Invoke-RestMethod -Uri "http://localhost:1234/v1/models" -TimeoutSec 5 -ErrorAction Stop
    if ($response.data.Count -gt 0) {
        $modelName = $response.data[0].id
        Write-Host " ✅ PASS (Model: $modelName)" -ForegroundColor Green
        $checksPass++
    }
    else {
        Write-Host " ⚠️  WARN - No models loaded" -ForegroundColor Yellow
    }
}
catch {
    Write-Host " ❌ FAIL - LM Studio API not responding" -ForegroundColor Red
}

# Check 7: OpenHands HTTP endpoint accessible
$checksTotal++
Write-Host "Check 7/10: OpenHands HTTP endpoint accessible..." -NoNewline -ForegroundColor Gray
try {
    # Extract port from docker ps output
    if ($portMatch) {
        $testUrl = "http://localhost:$port/"
        $response = Invoke-RestMethod -Uri $testUrl -TimeoutSec 5 -ErrorAction Stop
        Write-Host " ✅ PASS" -ForegroundColor Green
        $checksPass++
    }
    else {
        Write-Host " ⚠️  WARN - Could not determine port" -ForegroundColor Yellow
    }
}
catch {
    Write-Host " ⚠️  WARN - Port not yet responding (normal during init)" -ForegroundColor Yellow
}

# Check 8: docker-compose.yml valid
$checksTotal++
Write-Host "Check 8/10: docker-compose.yml valid..." -NoNewline -ForegroundColor Gray
$composePath = Join-Path $phase3Path "docker-compose.yml"
try {
    $output = docker compose -f $composePath config 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ PASS" -ForegroundColor Green
        $checksPass++
    }
    else {
        Write-Host " ❌ FAIL - Invalid compose file" -ForegroundColor Red
    }
}
catch {
    Write-Host " ❌ FAIL - Could not validate compose file" -ForegroundColor Red
}

# Check 9: README.md exists
$checksTotal++
Write-Host "Check 9/10: README.md documentation exists..." -NoNewline -ForegroundColor Gray
$readmePath = Join-Path $phase3Path "README.md"
if (Test-Path $readmePath) {
    Write-Host " ✅ PASS" -ForegroundColor Green
    $checksPass++
}
else {
    Write-Host " ❌ FAIL - README.md not found" -ForegroundColor Red
}

# Check 10: find-available-port.ps1 script exists
$checksTotal++
Write-Host "Check 10/10: find-available-port.ps1 script available..." -NoNewline -ForegroundColor Gray
$scriptPath = Join-Path $phase3Path "find-available-port.ps1"
if (Test-Path $scriptPath) {
    Write-Host " ✅ PASS" -ForegroundColor Green
    $checksPass++
}
else {
    Write-Host " ❌ FAIL - Script not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║ Results: $checksPass/$checksTotal PASS" -ForegroundColor $(if ($checksPass -ge 8) { "Green" } else { "Yellow" }) 
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if ($checksPass -ge 8) {
    Write-Host "✨ Phase 3 est prêt !" -ForegroundColor Green
    Write-Host ""
    Write-Host "Accéder à OpenHands : http://localhost:$port" -ForegroundColor Green
    Write-Host "Vérifier les logs   : docker compose -f $composePath logs --tail 50" -ForegroundColor Cyan
    Write-Host ""
}
elseif ($checksPass -ge 5) {
    Write-Host "⚠️  Plusieurs vérifications en attente (initialisation en cours)" -ForegroundColor Yellow
}
else {
    Write-Host "❌ Erreurs détectées. Consultez les résultats ci-dessus." -ForegroundColor Red
}
