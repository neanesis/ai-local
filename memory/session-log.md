# AI Local — Journal des Sessions de Travail

> Une entrée par session. Garder les 10 dernières ici, archiver le reste.
> **Archive** : déplacer les entrées excédentaires dans `memory/session-log-archive.md` (jamais lire en entier — Grep uniquement).
> Charger ce fichier en début de session pour reprendre là où tu t'es arrêté.

---

## Session : 2026-07-23 — Création du projet ai-local

**Durée** : ~1h  
**Modèle utilisé** : Claude (GitHub Copilot)  
**Outil principal** : GitHub Copilot Chat (VS Code)

### Ce qui a été fait

- Analyse critique de l'architecture Ollama + Open WebUI + OpenHands pour usage solo
- Décision : stack minimale LM Studio + Continue + Aider + Open WebUI
- Création complète du projet `ai-local` avec 19 fichiers
- Structure en 3 phases progressives avec scripts de validation PowerShell
- Création des templates de mémoire projet
- Initialisation Git + push sur GitHub : https://github.com/neanesis/ai-local
- Installation de GitHub CLI (gh) via winget

### Fichiers créés

- `README.md` — vue d'ensemble et démarrage rapide
- `phase1/README.md` — LM Studio + Continue + Aider (guide complet)
- `phase1/continue/config.json` — config Continue pour LM Studio
- `phase1/aider/.aider.conf.yml` — config Aider pour LM Studio
- `phase1/validate-phase1.ps1` — script de validation automatisée
- `phase2/README.md` — Open WebUI Docker
- `phase2/docker-compose.yml` — Open WebUI avec host.docker.internal
- `phase2/.env.example` — variables d'environnement
- `phase2/validate-phase2.ps1` — script de validation
- `phase3/README.md` — OpenHands (optionnel, décision explicite requise)
- `phase3/docker-compose.yml` — OpenHands
- `phase3/.env.example`
- `phase3/validate-phase3.ps1`
- `memory/` — 5 templates de mémoire projet

### Ce qui reste à faire (prochaine session)

- Ouvrir le dossier `ai-local` dans VS Code sur la machine cible
- Suivre `phase1/README.md` étape par étape
- Télécharger les modèles dans LM Studio (Qwen2.5-Coder-14B-Instruct Q4_K_M en priorité)
- Remplir les templates `memory/` avec le contexte de votre projet cible
- Lancer `phase1/validate-phase1.ps1` pour valider

### Décisions techniques importantes

- OpenHands NON installé par défaut — Phase 3 optionnelle avec critères explicites
- LM Studio sur Windows natif (pas Docker) pour accès GPU direct
- Open WebUI en Docker avec `host.docker.internal` pour joindre LM Studio
- Modèle principal recommandé : Qwen2.5-Coder-14B-Instruct Q4_K_M (~9-10 Go VRAM)
- Mémoire projet : fichiers Markdown versionnés dans le repo (pas de base vectorielle)

### Contexte important pour la prochaine session

> Ce repo `ai-local` est un environnement AI local autonome.
> Il peut être adapté à n'importe quel projet de développement.
> Machine cible : RTX 5080 16 Go VRAM, Ryzen 9 5900X, 32 Go RAM, Windows 11.
> LM Studio est déjà installé sur la machine cible.

---

<!-- 
TEMPLATE pour nouvelle session :

## Session : YYYY-MM-DD — [Titre]

**Durée** :   
**Modèle utilisé** :   
**Outil principal** :  

### Ce qui a été fait

- 

### Fichiers modifiés

- 

### Ce qui reste à faire

- 

### Problèmes rencontrés / décisions prises

- 

### Contexte important pour la prochaine session

> 

-->
