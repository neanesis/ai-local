# Phase 1 — LM Studio + Continue + Aider + Mémoire MealLoop

## Vue d'ensemble

Cette phase installe le noyau de l'environnement de développement local :
- **LM Studio** : moteur LLM, expose une API OpenAI-compatible
- **Continue** : assistant dans VS Code (chat + autocomplétion)
- **Aider** : agent CLI pour refactoring et patches multi-fichiers
- **Memory** : structure de mémoire persistante dans le repo MealLoop

Durée estimée : 30 à 60 minutes selon la vitesse de téléchargement des modèles.

---

## Étape 1 — LM Studio

### 1.1 Installation

Télécharger depuis : https://lmstudio.ai  
Version minimale recommandée : 0.3.x (avec support serveur API)

### 1.2 Télécharger les modèles

Dans LM Studio > onglet **Discover** ou **Search**, télécharger dans cet ordre :

1. **Qwen2.5-Coder-14B-Instruct** — chercher `qwen2.5-coder-14b-instruct`
   - Format recommandé : `Q4_K_M` (meilleur rapport qualité/vitesse)
   - Taille : ~9 Go
   
2. **Qwen2.5-Coder-7B-Instruct** — chercher `qwen2.5-coder-7b-instruct`
   - Format recommandé : `Q4_K_M`
   - Taille : ~5 Go

> Commencer par le 14B. Passer au 7B si la latence est trop élevée pour l'autocomplétion.

### 1.3 Configurer le serveur local

1. Aller dans l'onglet **Local Server** (icône `</>` dans la barre latérale)
2. Charger le modèle **Qwen2.5-Coder-14B-Instruct** dans le serveur
3. Vérifier les paramètres :
   - Port : `1234` (défaut)
   - Enable CORS : **activé**
   - Serve on local network : selon besoin
4. Cliquer **Start Server**

### 1.4 Vérifier que l'API répond

```powershell
# Doit retourner un JSON avec la liste des modèles chargés
Invoke-RestMethod -Uri "http://localhost:1234/v1/models" | ConvertTo-Json
```

### 1.5 Relever le nom exact du modèle

Le nom retourné par l'API est celui à utiliser dans les configs Continue et Aider.
Il ressemble à : `qwen2.5-coder-14b-instruct` ou au chemin de fichier complet.

```powershell
# Affiche l'ID exact du modèle actif
(Invoke-RestMethod -Uri "http://localhost:1234/v1/models").data.id
```

**Copier cet ID** — il sera nécessaire aux étapes 2 et 3.

### 1.6 Paramètres GPU recommandés

Dans LM Studio, lorsque tu charges le modèle :
- **GPU Layers** : mettre à `-1` (tout sur GPU) ou au maximum
- **Context Length** : 8192 pour usage quotidien (16384 si besoin analyse complète)
- **CPU Threads** : 8 à 12 (Ryzen 9 5900X)

---

## Étape 2 — Continue (VS Code)

### 2.1 Installer l'extension

Dans VS Code :
```
Extensions > Rechercher "Continue" > Installer "Continue - Codestral, Claude, and more"
```
Ou via la ligne de commande :
```powershell
code --install-extension Continue.continue
```

### 2.2 Appliquer la configuration

Copier le fichier de config vers le dossier Continue :

```powershell
# Créer le dossier si nécessaire
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.continue"

# Copier la config depuis ce dépôt
Copy-Item -Path "phase1\continue\config.json" -Destination "$env:USERPROFILE\.continue\config.json" -Force
```

### 2.3 Ajuster le nom du modèle

Ouvrir `%USERPROFILE%\.continue\config.json` et remplacer les occurrences de
`REMPLACER_PAR_ID_MODELE_LMSTUDIO` par l'ID exact relevé à l'étape 1.5.

Exemple :
```json
"model": "qwen2.5-coder-14b-instruct"
```

### 2.4 Vérifier dans VS Code

1. Redémarrer VS Code (ou recharger la fenêtre : `Ctrl+Shift+P > Reload Window`)
2. Ouvrir la sidebar Continue (`Ctrl+L` ou icône Continue)
3. Un message de chat doit s'afficher sans erreur de connexion
4. Envoyer un message test : `Hello, can you see my project?`

### 2.5 Raccourcis clés Continue

| Raccourci        | Action                              |
|------------------|-------------------------------------|
| `Ctrl+L`         | Ouvrir le chat Continue             |
| `Ctrl+I`         | Mode édition en ligne (inline edit) |
| `Ctrl+Shift+L`   | Ajouter la sélection au contexte    |
| `@codebase`      | Indexer et interroger tout le repo  |
| `@file`          | Ajouter un fichier au contexte      |

---

## Étape 3 — Aider

### 3.1 Prérequis Python

```powershell
# Vérifier Python (3.9+ requis)
python --version

# Vérifier pip
pip --version
```

Si Python n'est pas installé : https://www.python.org/downloads/

### 3.2 Installer Aider

```powershell
# Installation via pip (environnement global ou venv)
pip install aider-chat

# Vérifier l'installation
aider --version
```

> Si tu préfères un environnement virtuel isolé :
> ```powershell
> python -m venv $env:USERPROFILE\.venvs\aider
> & $env:USERPROFILE\.venvs\aider\Scripts\Activate.ps1
> pip install aider-chat
> ```

### 3.3 Déployer la configuration dans MealLoop

Copier le fichier de config Aider à la racine de ton repo MealLoop :

```powershell
# Adapter le chemin vers ton repo MealLoop
$mealloopPath = "C:\chemin\vers\MealLoop"

Copy-Item -Path "phase1\aider\.aider.conf.yml" -Destination "$mealloopPath\.aider.conf.yml" -Force
```

### 3.4 Ajuster le nom du modèle dans .aider.conf.yml

Ouvrir `$mealloopPath\.aider.conf.yml` et remplacer `REMPLACER_PAR_ID_MODELE_LMSTUDIO`
par l'ID exact relevé à l'étape 1.5.

Format attendu par Aider : `openai/<model-id>`  
Exemple : `openai/qwen2.5-coder-14b-instruct`

### 3.5 Vérifier Aider

```powershell
cd $mealloopPath

# Test de connexion : doit afficher la liste des fichiers et un prompt >
aider --no-auto-commits --message "Hello, list the main files in this project"
```

Si Aider répond sans erreur de connexion, il est opérationnel.

### 3.6 Utilisation typique Aider pour MealLoop

```powershell
# Ouvrir une session sur des fichiers spécifiques
aider lib/screens/meal_plan_screen.dart lib/services/meal_service.dart

# Laisser Aider découvrir le contexte automatiquement
aider --auto-test

# Mode lecture seule pour analyse sans modification
aider --read-only lib/models/
```

---

## Étape 4 — Structure Mémoire MealLoop

La mémoire projet est un ensemble de fichiers Markdown versionnés dans ton repo MealLoop.
Ils servent de contexte persistant fourni aux modèles entre les sessions.

### 4.1 Créer le dossier memory dans MealLoop

```powershell
$mealloopPath = "C:\chemin\vers\MealLoop"
$memoryPath = "$mealloopPath\memory"

New-Item -ItemType Directory -Force -Path $memoryPath
```

### 4.2 Copier les templates de mémoire

```powershell
Copy-Item -Path "memory\*" -Destination $memoryPath -Recurse -Force
```

### 4.3 Remplir les templates

Ouvrir chaque fichier et remplir les sections marquées `[À COMPLÉTER]` :

| Fichier                      | Contenu                                          | Priorité    |
|------------------------------|--------------------------------------------------|-------------|
| `project-context.md`         | Architecture MealLoop, stack, Supabase schema   | **Critique** |
| `conventions.md`             | Conventions de nommage, patterns Flutter utilisés | **Critique** |
| `architecture-decisions.md`  | Décisions techniques importantes déjà prises     | Importante  |
| `session-log.md`             | Remplir à chaque session de travail              | Continue    |

### 4.4 Utiliser la mémoire avec Continue

```
# Dans le chat Continue, référencer la mémoire :
@file memory/project-context.md
Continue the implementation of the meal planning feature based on this context.

# Ou utiliser @codebase pour tout indexer
@codebase
What is the current state of the meal planning feature?
```

### 4.5 Utiliser la mémoire avec Aider

```powershell
# Aider lit automatiquement .aider.conf.yml qui peut inclure des fichiers de contexte
# Ou ajouter manuellement en session :
aider lib/screens/meal_plan_screen.dart /read-only memory/project-context.md
```

---

## Validation Phase 1

Une fois toutes les étapes complétées, lancer le script de validation :

```powershell
.\phase1\validate-phase1.ps1
```

Le script vérifie automatiquement :
- LM Studio API active et modèle chargé
- Extension Continue installée dans VS Code
- Aider disponible dans le PATH
- Structure mémoire présente dans MealLoop

**Ne pas passer à la Phase 2 tant que tous les checks ne sont pas verts.**

---

## Troubleshooting Phase 1

### LM Studio : "Connection refused" sur le port 1234

1. Vérifier que LM Studio est ouvert et que le serveur est démarré (bouton vert)
2. Vérifier qu'aucun firewall Windows ne bloque le port 1234
3. Vérifier le port dans LM Studio Settings > API Server

### Continue : "No model found" ou spinner infini

1. Vérifier que LM Studio tourne avec un modèle chargé
2. Vérifier `%USERPROFILE%\.continue\config.json` — l'`apiBase` doit être `http://localhost:1234/v1`
3. Vérifier le nom du modèle dans la config (sensible à la casse)
4. Dans VS Code : `Ctrl+Shift+P > Continue: Open Logs` pour voir l'erreur exacte

### Aider : "Model not found" ou erreur OpenAI

1. Vérifier que LM Studio tourne
2. Vérifier `.aider.conf.yml` — le modèle doit avoir le préfixe `openai/`
3. Exemple valide : `model: openai/qwen2.5-coder-14b-instruct`
4. Vérifier avec : `aider --list-models openai/` pour voir les modèles disponibles

### Aider : erreur "git not found"

```powershell
# Vérifier que git est dans le PATH
git --version

# Si absent, installer Git : https://git-scm.com/download/win
```
