# Script de validation Phase 3
# Vérifie : Docker, conteneur OpenHands, connexion LM Studio depuis OpenHands
# Usage : .\phase3\validate-phase3.ps1

$passed = 0
$failed = 0
$warnings = 0

function Write-Pass([string]$msg) {
    Write-Host "  [PASS] $msg" -ForegroundColor Green
    $script:passed++
}
function Write-Fail([string]$msg) {
    Write-Host "  [FAIL] $msg" -ForegroundColor Red
    $script:failed++
}
function Write-Warn([string]$msg) {
    Write-Host "  [WARN] $msg" -ForegroundColor Yellow
    $script:warnings++
}
function Write-Section([string]$msg) {
    Write-Host ""
    Write-Host "=== $msg ===" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  VALIDATION PHASE 3 — OpenHands" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# ===================================================================
Write-Section "0. Prérequis — Phases 1 et 2"

try {
    $null = Invoke-RestMethod -Uri "http://localhost:1234/v1/models" -TimeoutSec 5 -ErrorAction Stop
    Write-Pass "LM Studio API opérationnelle"
} catch {
    Write-Fail "LM Studio API inaccessible. Vérifier Phase 1."
}

try {
    $webResponse = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Pass "Open WebUI accessible (Phase 2 OK)"
} catch {
    Write-Warn "Open WebUI inaccessible sur port 3000. Phase 2 peut ne pas être active."
}

# ===================================================================
Write-Section "1. Fichier .env Phase 3"

$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Write-Pass "Fichier .env présent"

    $envContent = Get-Content $envFile -Raw
    if ($envContent -match "REMPLACER_PAR_ID_MODELE_LMSTUDIO") {
        Write-Fail "LLM_MODEL n'a pas été configuré. Modifier le fichier .env."
    } else {
        Write-Pass "LLM_MODEL configuré"
    }
} else {
    Write-Fail "Fichier .env absent. Copier .env.example en .env et configurer LLM_MODEL."
}

# ===================================================================
Write-Section "2. Conteneur OpenHands"

try {
    $containerStatus = & docker inspect --format "{{.State.Status}}" openhands 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Conteneur 'openhands' absent. Lancer : docker compose up -d (depuis phase3\)"
    } elseif ($containerStatus -eq "running") {
        Write-Pass "Conteneur OpenHands en cours d'exécution"
    } else {
        Write-Fail "Conteneur OpenHands état : $containerStatus"
    }
} catch {
    Write-Fail "Erreur vérification conteneur : $($_.Exception.Message)"
}

# ===================================================================
Write-Section "3. Accessibilité OpenHands"

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Pass "OpenHands accessible sur http://localhost:3001 (HTTP $($response.StatusCode))"
} catch {
    Write-Fail "OpenHands inaccessible sur http://localhost:3001"
    Write-Host "         Vérifier : docker compose logs openhands --tail 30" -ForegroundColor DarkGray
}

# ===================================================================
Write-Section "4. Connexion LM Studio depuis OpenHands"

try {
    $curlResult = & docker exec openhands curl -s --max-time 5 http://host.docker.internal:1234/v1/models 2>&1
    if ($LASTEXITCODE -eq 0 -and $curlResult -match "data") {
        Write-Pass "OpenHands peut atteindre LM Studio via host.docker.internal:1234"
    } else {
        Write-Fail "OpenHands ne peut pas atteindre LM Studio"
        Write-Host "         Résultat : $curlResult" -ForegroundColor DarkGray
    }
} catch {
    Write-Warn "Impossible de tester depuis Docker : $($_.Exception.Message)"
}

# ===================================================================
Write-Section "Résumé"

Write-Host ""
Write-Host "  Passed   : $passed" -ForegroundColor Green
Write-Host "  Failed   : $failed" -ForegroundColor Red
Write-Host "  Warnings : $warnings" -ForegroundColor Yellow
Write-Host ""

if ($failed -eq 0) {
    Write-Host "  PHASE 3 VALIDEE." -ForegroundColor Green
    Write-Host "  Accéder à OpenHands : http://localhost:3001" -ForegroundColor Green
} else {
    Write-Host "  PHASE 3 INCOMPLETE — Corriger les erreurs avant utilisation." -ForegroundColor Red
    Write-Host "  Consulter phase3\README.md pour le détail des étapes." -ForegroundColor DarkGray
}

Write-Host ""
