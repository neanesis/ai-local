# Système de Mémoire Projet — Guide

## Objectif

Ce dossier contient la **mémoire persistante** de votre projet.
Il sert de contexte fourni aux modèles LLM locaux (Continue, Aider, Open WebUI)
pour qu'ils comprennent le projet sans que tu aies à tout réexpliquer à chaque session.

## Principe de fonctionnement

```
Tu commences une session → tu charges le contexte → le modèle comprend immédiatement
```

Contrairement aux services cloud qui gardent l'historique entre sessions, les modèles locaux
démarrent "vides". Ces fichiers compensent cette limitation.

## Fichiers et leur rôle

| Fichier                      | Mise à jour          | Contenu                                    |
|------------------------------|----------------------|--------------------------------------------|
| `project-context.md`         | Rarement (si arch change) | Stack, architecture, schéma Supabase  |
| `conventions.md`             | Rarement             | Nommage, patterns, règles de code          |
| `architecture-decisions.md`  | À chaque décision    | Log des décisions techniques importantes   |
| `session-log.md`             | À chaque session     | Ce qui a été fait, ce qui reste à faire    |

## Règles d'économie de tokens

### Classification des fichiers

| Classe | Fichier | Règle |
|--------|---------|-------|
| **A** — chargé à chaque session | `session-log.md`, `project-context.md` | Charger systématiquement, garder < 30 Ko au total |
| **B** — chargé à la demande | `conventions.md`, `architecture-decisions.md` | Charger uniquement si la tâche le nécessite |
| **C** — archive, jamais lu en entier | `session-log-archive.md` | **Grep ciblé uniquement**, puis `read_file` sur la plage trouvée |

### Règles de lecture

- **Jamais** de lecture intégrale des fichiers Class C (archives).
- Pour les gros fichiers source (> 800 lignes) : Grep du symbole d'abord, puis lecture ciblée.
- **Contrôle périodique** : si `session-log.md` dépasse ~10 entrées → déplacer les anciennes vers `session-log-archive.md`.
- Viser < 30 Ko au total pour les fichiers Class A :
  ```powershell
  Get-ChildItem memory -File | Where-Object Name -in 'session-log.md','project-context.md' | Measure-Object Length -Sum
  ```

---

## Comment charger le contexte

### Continue (VS Code)

```
# Charger le contexte en début de session
@file memory/project-context.md
@file memory/session-log.md

# Puis poser ta question
What is the current state of the meal planning feature?
```

### Aider (terminal)

```powershell
# Ajouter les fichiers mémoire en lecture seule au contexte Aider
aider lib/screens/meal_plan_screen.dart \
  /read-only memory/project-context.md \
  /read-only memory/conventions.md
```

Ou décommenter le bloc `read:` dans `.aider.conf.yml` pour charger
automatiquement `project-context.md` et `conventions.md` à chaque session.

### Open WebUI

Coller le contenu de `project-context.md` dans le System Prompt de votre workspace
Open WebUI, ou le copier-coller en début de conversation.

## Discipline de mise à jour

**À chaque fin de session de travail :**
1. Ouvrir `session-log.md`
2. Ajouter une entrée avec la date, ce qui a été fait, et ce qui reste
3. Commiter avec le code : `git add memory/ && git commit -m "chore: update session log"`

**Quand une décision technique importante est prise :**
1. Ouvrir `architecture-decisions.md`
2. Ajouter une entrée ADR
3. Commiter immédiatement

## Taille et performance

Garder les fichiers mémoire **concis**. Un modèle local avec 8192 tokens de contexte
ne peut pas ingérer des fichiers trop longs sans dégrader la qualité des réponses.

Recommandations :
- `project-context.md` : < 500 lignes
- `conventions.md` : < 200 lignes
- `session-log.md` : garder les 10 dernières sessions, archiver le reste
