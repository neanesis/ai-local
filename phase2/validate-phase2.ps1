# Script de validation Phase 2
# Vérifie : Docker, conteneur Open WebUI, connexion LM Studio depuis Docker
# Usage : .\phase2\validate-phase2.ps1

# Compteurs de résultats
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

# ===================================================================
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  VALIDATION PHASE 2 — Open WebUI" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# ===================================================================
Write-Section "0. Prérequis — Phase 1"

# Vérifier que LM Studio répond encore (prérequis Phase 1)
try {
    $null = Invoke-RestMethod -Uri "http://localhost:1234/v1/models" -TimeoutSec 5 -ErrorAction Stop
    Write-Pass "LM Studio API opérationnelle (prérequis Phase 1 OK)"
} catch {
    Write-Fail "LM Studio API inaccessible. Démarrer LM Studio avant de valider Phase 2."
}

# ===================================================================
Write-Section "1. Docker Desktop"

# 1.1 Vérifier que docker est dans le PATH
$dockerCmd = Get-Command "docker" -ErrorAction SilentlyContinue
if (-not $dockerCmd) {
    Write-Fail "Docker non trouvé dans le PATH. Docker Desktop n'est pas installé ou pas démarré."
} else {
    Write-Pass "Docker CLI trouvé : $($dockerCmd.Source)"

    # 1.2 Vérifier que le daemon Docker répond
    try {
        $dockerInfo = & docker version --format "{{.Server.Version}}" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Pass "Docker daemon actif. Version serveur : $dockerInfo"
        } else {
            Write-Fail "Docker daemon inaccessible. Démarrer Docker Desktop."
        }
    } catch {
        Write-Fail "Erreur Docker : $($_.Exception.Message)"
    }

    # 1.3 Vérifier docker compose
    $composeVersion = & docker compose version --short 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Pass "Docker Compose disponible : v$composeVersion"
    } else {
        Write-Fail "Docker Compose non disponible. Mettre à jour Docker Desktop."
    }
}

# ===================================================================
Write-Section "2. Fichier .env"

$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Write-Pass "Fichier .env présent"

    # Vérifier que la clé n'est pas le placeholder
    $envContent = Get-Content $envFile -Raw
    if ($envContent -match "CHANGEME_GENERATE_RANDOM_KEY") {
        Write-Fail "La clé WEBUI_SECRET_KEY n'a pas été générée. Modifier le fichier .env."
    } else {
        Write-Pass "WEBUI_SECRET_KEY configurée"
    }
} else {
    Write-Fail "Fichier .env absent. Copier .env.example en .env et générer la clé secrète."
}

# ===================================================================
Write-Section "3. Conteneur Open WebUI"

try {
    # 3.1 Vérifier que le conteneur existe et son état
    $containerStatus = & docker inspect --format "{{.State.Status}}" open-webui 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Conteneur 'open-webui' absent. Lancer : docker compose up -d (depuis phase2\)"
    } else {
        if ($containerStatus -eq "running") {
            Write-Pass "Conteneur open-webui en cours d'exécution"

            # 3.2 Vérifier le healthcheck
            $healthStatus = & docker inspect --format "{{.State.Health.Status}}" open-webui 2>&1
            if ($healthStatus -eq "healthy") {
                Write-Pass "Healthcheck open-webui : healthy"
            } elseif ($healthStatus -eq "starting") {
                Write-Warn "Healthcheck open-webui : starting (attendre 30 secondes et relancer)"
            } else {
                Write-Warn "Healthcheck open-webui : $healthStatus"
            }
        } else {
            Write-Fail "Conteneur open-webui état : $containerStatus. Lancer : docker compose up -d"
        }
    }
} catch {
    Write-Fail "Erreur lors de la vérification du conteneur : $($_.Exception.Message)"
}

# ===================================================================
Write-Section "4. Accessibilité Open WebUI"

# 4.1 Vérifier que Open WebUI répond sur le port 3000
try {
    $webResponse = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($webResponse.StatusCode -eq 200) {
        Write-Pass "Open WebUI accessible sur http://localhost:3000 (HTTP $($webResponse.StatusCode))"
    } else {
        Write-Warn "Open WebUI répond avec HTTP $($webResponse.StatusCode) sur http://localhost:3000"
    }
} catch {
    Write-Fail "Open WebUI inaccessible sur http://localhost:3000"
    Write-Host "         Cause : $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "         Vérifier : docker compose logs open-webui --tail 20" -ForegroundColor DarkGray
}

# 4.2 Vérifier l'endpoint health de Open WebUI
try {
    $healthResp = Invoke-RestMethod -Uri "http://localhost:3000/health" -TimeoutSec 5 -ErrorAction Stop
    Write-Pass "Endpoint /health Open WebUI : OK"
} catch {
    Write-Warn "Endpoint /health non disponible (peut être normal selon la version)"
}

# ===================================================================
Write-Section "5. Connexion LM Studio depuis Docker"

# Tester si le conteneur peut atteindre LM Studio via host.docker.internal
try {
    $curlResult = & docker exec open-webui curl -s --max-time 5 http://host.docker.internal:1234/v1/models 2>&1
    if ($LASTEXITCODE -eq 0 -and $curlResult -match "data") {
        Write-Pass "Open WebUI peut atteindre LM Studio via host.docker.internal:1234"
    } else {
        Write-Fail "Open WebUI ne peut pas atteindre LM Studio"
        Write-Host "         Résultat curl : $curlResult" -ForegroundColor DarkGray
        Write-Host "         Vérifier : LM Studio > Server > 'Serve on local network' activé" -ForegroundColor DarkGray
    }
} catch {
    Write-Warn "Impossible de tester la connexion depuis Docker : $($_.Exception.Message)"
}

# ===================================================================
Write-Section "Résumé"

Write-Host ""
Write-Host "  Passed   : $passed" -ForegroundColor Green
Write-Host "  Failed   : $failed" -ForegroundColor Red
Write-Host "  Warnings : $warnings" -ForegroundColor Yellow
Write-Host ""

if ($failed -eq 0) {
    Write-Host "  PHASE 2 VALIDEE." -ForegroundColor Green
    Write-Host "  Accéder à Open WebUI : http://localhost:3000" -ForegroundColor Green
    Write-Host "  La Phase 3 (OpenHands) est optionnelle — ne l'installer que si nécessaire." -ForegroundColor DarkGray
} else {
    Write-Host "  PHASE 2 INCOMPLETE — Corriger les erreurs avant utilisation." -ForegroundColor Red
    Write-Host "  Consulter phase2\README.md pour le détail des étapes." -ForegroundColor DarkGray
}

Write-Host ""
