# Script de validation Phase 1
# Vérifie : LM Studio API, Continue extension, Aider CLI, structure mémoire
# Usage : .\phase1\validate-phase1.ps1

param(
    # Chemin optionnel vers votre repo projet (pour vérifier la structure mémoire)
    [string]$ProjectPath = ""
)

# --- Configuration ---
$LmStudioApiUrl  = "http://localhost:1234/v1"
$ContinueExtId   = "Continue.continue"

# Compteurs de résultats
$passed = 0
$failed = 0
$warnings = 0

# Fonctions d'affichage
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
Write-Host "  VALIDATION PHASE 1 — AI Local" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# ===================================================================
Write-Section "1. LM Studio — API"

# 1.1 Vérifier que l'API répond
try {
    $response = Invoke-RestMethod -Uri "$LmStudioApiUrl/models" -TimeoutSec 5 -ErrorAction Stop
    Write-Pass "LM Studio API répond sur $LmStudioApiUrl"

    # 1.2 Vérifier qu'un modèle est chargé
    if ($response.data -and $response.data.Count -gt 0) {
        $modelId = $response.data[0].id
        Write-Pass "Modèle actif détecté : $modelId"
        Write-Host "         (Utiliser cet ID dans les configs Continue et Aider)" -ForegroundColor DarkGray
    } else {
        Write-Fail "Aucun modèle chargé dans LM Studio. Charger un modèle dans Local Server."
    }
} catch {
    Write-Fail "LM Studio API inaccessible sur $LmStudioApiUrl"
    Write-Host "         Cause : $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "         Action : LM Studio > Local Server > Start Server" -ForegroundColor DarkGray
}

# 1.3 Vérifier CORS (test simple)
try {
    $headers = @{ "Origin" = "http://localhost:3000" }
    $null = Invoke-WebRequest -Uri "$LmStudioApiUrl/models" -Headers $headers -TimeoutSec 5 -ErrorAction Stop
    Write-Pass "CORS : LM Studio accepte les requêtes cross-origin"
} catch {
    Write-Warn "CORS : impossible de vérifier. S'assurer que 'Enable CORS' est activé dans LM Studio."
}

# ===================================================================
Write-Section "2. Continue — Extension VS Code"

# 2.1 Vérifier que code.exe est accessible
$codeExe = Get-Command "code" -ErrorAction SilentlyContinue
if (-not $codeExe) {
    Write-Fail "VS Code 'code' n'est pas dans le PATH. Ajouter VS Code au PATH ou relancer le terminal."
} else {
    Write-Pass "VS Code CLI trouvé : $($codeExe.Source)"

    # 2.2 Vérifier que l'extension Continue est installée
    $extensions = & code --list-extensions 2>$null
    if ($extensions -match [regex]::Escape($ContinueExtId)) {
        Write-Pass "Extension Continue installée ($ContinueExtId)"
    } else {
        Write-Fail "Extension Continue non trouvée. Installer via : code --install-extension $ContinueExtId"
    }
}

# 2.3 Vérifier que le fichier de config existe
$continueConfigPath = Join-Path $env:USERPROFILE ".continue\config.json"
if (Test-Path $continueConfigPath) {
    Write-Pass "Fichier de config Continue présent : $continueConfigPath"

    # 2.4 Vérifier que la config ne contient pas le placeholder
    $configContent = Get-Content $continueConfigPath -Raw
    if ($configContent -match "REMPLACER_PAR_ID_MODELE_LMSTUDIO") {
        Write-Fail "Le placeholder 'REMPLACER_PAR_ID_MODELE_LMSTUDIO' n'a pas été remplacé dans config.json"
    } else {
        Write-Pass "Config Continue : aucun placeholder détecté"
    }

    # 2.5 Vérifier que l'apiBase pointe vers LM Studio
    if ($configContent -match "localhost:1234") {
        Write-Pass "Config Continue : apiBase pointe vers LM Studio (localhost:1234)"
    } else {
        Write-Warn "Config Continue : 'localhost:1234' non trouvé. Vérifier l'apiBase dans config.json"
    }
} else {
    Write-Fail "Fichier de config Continue absent. Copier phase1\continue\config.json vers $continueConfigPath"
}

# ===================================================================
Write-Section "3. Aider — CLI"

# 3.1 Vérifier que aider est dans le PATH
$aiderCmd = Get-Command "aider" -ErrorAction SilentlyContinue
if (-not $aiderCmd) {
    Write-Fail "Aider non trouvé dans le PATH. Installer via : pip install aider-chat"
    Write-Host "         Puis relancer le terminal." -ForegroundColor DarkGray
} else {
    Write-Pass "Aider trouvé : $($aiderCmd.Source)"

    # 3.2 Vérifier la version
    try {
        $aiderVersion = & aider --version 2>&1
        Write-Pass "Version Aider : $aiderVersion"
    } catch {
        Write-Warn "Impossible de lire la version Aider : $($_.Exception.Message)"
    }
}

# 3.3 Vérifier le fichier .aider.conf.yml si ProjectPath fourni
if ($ProjectPath -ne "") {
    $aiderConf = Join-Path $ProjectPath ".aider.conf.yml"
    if (Test-Path $aiderConf) {
        Write-Pass "Fichier .aider.conf.yml présent dans le projet : $aiderConf"

        $aiderContent = Get-Content $aiderConf -Raw
        if ($aiderContent -match "REMPLACER_PAR_ID_MODELE_LMSTUDIO") {
            Write-Fail "Le placeholder n'a pas été remplacé dans .aider.conf.yml"
        } else {
            Write-Pass ".aider.conf.yml : aucun placeholder détecté"
        }

        if ($aiderContent -match "localhost:1234") {
            Write-Pass ".aider.conf.yml : pointe vers LM Studio (localhost:1234)"
        } else {
            Write-Warn ".aider.conf.yml : 'localhost:1234' non trouvé. Vérifier openai-api-base."
        }
    } else {
        Write-Warn "Fichier .aider.conf.yml absent dans $ProjectPath. Copier depuis phase1\aider\.aider.conf.yml"
    }
} else {
    Write-Warn "Paramètre -ProjectPath non fourni. Vérification Aider config ignorée."
    Write-Host "         Relancer avec : .\validate-phase1.ps1 -ProjectPath 'C:\chemin\votre-projet'" -ForegroundColor DarkGray
}

# ===================================================================
Write-Section "4. Structure Mémoire Projet"

if ($ProjectPath -ne "") {
    $memoryPath = Join-Path $ProjectPath "memory"
    $expectedFiles = @(
        "project-context.md",
        "architecture-decisions.md",
        "session-log.md",
        "conventions.md"
    )

    if (Test-Path $memoryPath) {
        Write-Pass "Dossier memory présent : $memoryPath"

        foreach ($file in $expectedFiles) {
            $filePath = Join-Path $memoryPath $file
            if (Test-Path $filePath) {
                # Vérifier si le fichier a été rempli (présence de placeholder)
                $content = Get-Content $filePath -Raw
                if ($content -match "\[À COMPLÉTER\]") {
                    Write-Warn "memory\$file : contient encore des placeholders [À COMPLÉTER]"
                } else {
                    Write-Pass "memory\$file : présent et rempli"
                }
            } else {
                Write-Warn "memory\$file : absent. Copier depuis le template."
            }
        }
    } else {
        Write-Warn "Dossier memory absent dans votre projet. Créer et copier les templates depuis memory\"
    }
} else {
    Write-Warn "Paramètre -ProjectPath non fourni. Vérification structure mémoire ignorée."
}

# ===================================================================
Write-Section "Résumé"

Write-Host ""
Write-Host "  Passed   : $passed" -ForegroundColor Green
Write-Host "  Failed   : $failed" -ForegroundColor Red
Write-Host "  Warnings : $warnings" -ForegroundColor Yellow
Write-Host ""

if ($failed -eq 0) {
    Write-Host "  PHASE 1 VALIDEE — Tu peux passer à la Phase 2." -ForegroundColor Green
    Write-Host "  (Corriger les avertissements est recommandé mais non bloquant)" -ForegroundColor DarkGray
} else {
    Write-Host "  PHASE 1 INCOMPLETE — Corriger les erreurs avant de passer à la Phase 2." -ForegroundColor Red
    Write-Host "  Consulter phase1\README.md pour le détail des étapes." -ForegroundColor DarkGray
}

Write-Host ""
