# AI Local — Remplacement local de Claude Code

## Objectif

Reproduire l'expérience Claude Code / Claude Cowork en local lorsque les quotas sont épuisés,
en s'appuyant sur des modèles LLM locaux adaptés au matériel disponible (RTX 5080, 16 Go VRAM).

Capacités couvertes :
- Compréhension d'un dépôt complet
- Navigation dans le code et analyse d'architecture
- Génération de code et refactoring multi-fichiers
- Exécution de commandes orientée patch
- Mémoire persistante du projet MealLoop
- Interface dans VS Code et interface web

## Architecture cible

```
Windows (natif)
├── LM Studio          → moteur LLM local, API OpenAI-compatible (port 1234)
├── VS Code + Continue → assistant intégré dans l'éditeur
└── Aider CLI          → agent refactoring / patches multi-fichiers via terminal

Docker
├── Open WebUI         → interface web pour sessions longues (Phase 2)
└── OpenHands          → agent autonome, optionnel (Phase 3)

MealLoop repo
└── memory/            → mémoire persistante projet, versionnée avec le code
```

## Installation progressive

| Phase | Composants                          | Prérequis        |
|-------|-------------------------------------|------------------|
| **1** | LM Studio + Continue + Aider + Memory | Rien            |
| **2** | Open WebUI (Docker)                 | Phase 1 validée  |
| **3** | OpenHands (Docker)                  | Phase 2 validée + besoin confirmé |

> **Règle principale : ne pas avancer à la phase suivante sans avoir validé la phase courante.**
> Chaque validation est automatisée via un script PowerShell.

## Matériel de référence

| Composant | Valeur                     |
|-----------|---------------------------|
| GPU       | RTX 5080 16 Go VRAM       |
| CPU       | Ryzen 9 5900X 12 cores    |
| RAM       | 32 Go                     |
| OS        | Windows 11                |

## Modèles recommandés (à télécharger dans LM Studio)

| Modèle                              | Usage principal              | VRAM estimée |
|-------------------------------------|------------------------------|--------------|
| Qwen2.5-Coder-14B-Instruct Q4_K_M  | Chat, refactoring, analyse   | ~9-10 Go     |
| Qwen2.5-Coder-7B-Instruct Q4_K_M   | Autocomplétion rapide        | ~5 Go        |
| DeepSeek-Coder-V2-Lite Q4_K_M      | Analyse architecture lourde  | ~9 Go        |

> Commencer avec Qwen2.5-Coder-14B-Instruct. Descendre sur 7B si la latence est trop élevée.

## Structure du dépôt

```
ai-local/
├── README.md                   ← ce fichier
├── phase1/
│   ├── README.md               ← guide d'installation Phase 1
│   ├── continue/
│   │   └── config.json         ← configuration Continue pour LM Studio
│   ├── aider/
│   │   └── .aider.conf.yml     ← configuration Aider pour LM Studio
│   └── validate-phase1.ps1     ← script de validation automatisée
├── phase2/
│   ├── README.md               ← guide d'installation Phase 2
│   ├── docker-compose.yml      ← Open WebUI
│   ├── .env.example            ← variables d'environnement à copier en .env
│   └── validate-phase2.ps1     ← script de validation automatisée
├── phase3/
│   ├── README.md               ← guide d'installation Phase 3
│   ├── docker-compose.yml      ← OpenHands
│   └── validate-phase3.ps1     ← script de validation automatisée
└── memory/
    ├── README.md               ← guide du système de mémoire
    ├── project-context.md      ← contexte permanent MealLoop
    ├── architecture-decisions.md ← journal des décisions techniques
    ├── session-log.md          ← journal des sessions de travail
    └── conventions.md          ← conventions de code MealLoop
```

## Démarrage rapide

```powershell
# Lire le guide Phase 1 et suivre les étapes
code phase1\README.md

# Valider Phase 1 avant de continuer
.\phase1\validate-phase1.ps1

# Lire le guide Phase 2 seulement si Phase 1 est validée
code phase2\README.md

# Valider Phase 2
.\phase2\validate-phase2.ps1
```

## Troubleshooting général

| Symptôme                           | Cause probable                   | Action                              |
|------------------------------------|----------------------------------|-------------------------------------|
| LM Studio API ne répond pas        | Serveur non démarré              | LM Studio > Local Server > Start    |
| Continue ne trouve pas le modèle   | Nom de modèle incorrect          | Voir phase1/README.md section config |
| Aider plante au démarrage          | Python/pip pas dans PATH         | Relancer le terminal en admin        |
| Open WebUI ne se connecte pas      | LM Studio non accessible depuis Docker | Vérifier host.docker.internal   |
