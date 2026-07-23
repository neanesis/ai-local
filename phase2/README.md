# Phase 2 — Open WebUI (Docker)

## Prérequis

- Phase 1 entièrement validée (`.\phase1\validate-phase1.ps1` sans erreurs)
- Docker Desktop installé et en cours d'exécution
- LM Studio en cours d'exécution avec un modèle chargé

---

## Objectif de cette phase

Ajouter une interface web locale pour :
- Sessions de chat longues sans passer par VS Code
- Comparaison de réponses sur plusieurs prompts
- Consultation du contexte projet dans un navigateur
- Accès depuis un autre appareil sur le réseau local (optionnel)

---

## Étape 1 — Préparer l'environnement

### 1.0 Gestion des conflits de port (si vous avez d'autres services sur localhost:3000)

Si vous avez d'autres services Docker/Windows utilisant le port 3000, utilisez le script de port dynamique :

```powershell
cd phase2

# Trouver le premier port disponible et redémarrer Open WebUI
.\find-available-port.ps1 -StartPort 3000 -Range 10
```

Ce script :
- Teste les ports 3000-3009 pour trouver le premier disponible
- Met à jour `docker-compose.yml` automatiquement
- Redémarre Open WebUI sur le port trouvé
- Affiche l'URL d'accès

**Exemple** : si port 3000 est occupé, il utilisera 3001 et affichera `http://localhost:3001`

### 1.1 Créer le fichier .env

```powershell
cd phase2

# Copier le fichier d'exemple et générer une clé secrète
Copy-Item .env.example .env

# Générer une clé secrète aléatoire (remplacer CHANGEME dans .env)
$secret = [System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
Write-Host "Clé générée : $secret"
```

Ouvrir `.env` et remplacer `CHANGEME_GENERATE_RANDOM_KEY` par la clé générée.

### 1.2 Vérifier que Docker est opérationnel

```powershell
# Doit afficher la version Docker
docker --version
docker compose version

# Vérifier que Docker Desktop est démarré
docker ps
```

---

## Étape 2 — Démarrer Open WebUI

```powershell
cd phase2

# Démarrer les services en arrière-plan
docker compose up -d

# Vérifier que le conteneur est démarré
docker compose ps
```

Le premier démarrage télécharge l'image (~1 Go). Attendre que le statut passe à `healthy`.

---

## Étape 3 — Vérifier l'accès

```powershell
# Vérifier que le service répond
Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing | Select-Object StatusCode
```

Ouvrir dans un navigateur : http://localhost:3000

**Premier accès :**
1. Créer un compte administrateur local (aucune donnée n'est envoyée en ligne)
2. Aller dans **Settings > Connections**
3. Vérifier que l'URL OpenAI pointe vers `http://host.docker.internal:1234/v1`
4. Tester la connexion — doit afficher le modèle LM Studio

---

## Étape 4 — Configuration Open WebUI

### 4.1 Ajouter le contexte projet comme System Prompt

Dans Open WebUI > **Settings > Interface > System Prompt** :

```
You are an expert software development assistant.

Always:
- Follow the conventions established in the project
- Prefer minimal, maintainable solutions over complex architectures
- Provide code changes with English comments explaining modifications
- Ask for clarification when the task or context is ambiguous
```

### 4.2 Créer un Workspace projet (optionnel)

Dans Open WebUI, les "Workspaces" permettent de sauvegarder le contexte entre sessions.

---

## Commandes Docker utiles

```powershell
# Voir les logs en temps réel
docker compose logs -f

# Arrêter les services
docker compose down

# Redémarrer
docker compose restart

# Mettre à jour l'image Open WebUI
docker compose pull
docker compose up -d
```

---

## Validation Phase 2

```powershell
.\phase2\validate-phase2.ps1
```

---

## Troubleshooting Phase 2

### Open WebUI ne se connecte pas à LM Studio

`host.docker.internal` est le nom DNS Docker pour atteindre `localhost` de Windows.

Vérifier :
1. LM Studio est bien démarré avec le serveur actif
2. Dans LM Studio : **Serve on local network** est activé
3. Windows Firewall ne bloque pas le port 1234

Test depuis l'intérieur du conteneur :
```powershell
docker exec open-webui curl -s http://host.docker.internal:1234/v1/models
```

### Open WebUI inaccessible sur port 3000

```powershell
# Vérifier quel service utilise le port 3000
netstat -ano | findstr :3000

# Changer le port dans docker-compose.yml si conflit :
# "3001:8080" au lieu de "3000:8080"
```

### Conteneur en état "unhealthy"

```powershell
# Voir les logs du conteneur
docker compose logs open-webui --tail 50

# Redémarrer proprement
docker compose down
docker compose up -d
```

### Données persistantes

Les données Open WebUI (comptes, historique, modèles configurés) sont stockées
dans le volume Docker nommé `open-webui-data`.

```powershell
# Voir le volume
docker volume inspect open-webui-data

# Backup du volume (optionnel)
docker run --rm -v open-webui-data:/data -v ${PWD}:/backup alpine tar czf /backup/open-webui-backup.tar.gz /data
```
