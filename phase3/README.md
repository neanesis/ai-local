# Phase 3 — OpenHands (Optionnel)

## À lire avant d'installer

Cette phase est **optionnelle**. Ne l'installer que si tu as confirmé un besoin
réel que les Phases 1 et 2 ne couvrent pas.

### Quand OpenHands apporte une valeur réelle

| Besoin concret                                   | OpenHands utile ? |
|--------------------------------------------------|-------------------|
| Refactoring multi-fichiers interactif            | Non — Aider suffit |
| Session de chat longue avec contexte             | Non — Open WebUI suffit |
| Génération de code guidée dans VS Code           | Non — Continue suffit |
| Tâche autonome longue (ex: écrire 20 tests)      | **Oui** |
| Exploration d'un bug complexe sans supervision   | **Oui** |
| Génération d'un module complet en mode batch     | **Oui** |

> **Règle de décision** : si tu dois superviser chaque étape, OpenHands n'apporte
> pas grand-chose par rapport à Aider. Si tu veux déléguer une tâche et revenir voir
> le résultat, OpenHands a du sens.

### Coûts réels à prendre en compte

- **Complexité** : OpenHands est un orchestrateur multi-agents. Quand ça plante, le debug est non trivial.
- **VRAM** : utilise le même backend LM Studio, donc pas de VRAM supplémentaire, mais la charge est plus intense.
- **Maintenance** : les images OpenHands évoluent vite. Des breaking changes arrivent régulièrement.
- **Latence** : les tâches autonomes consomment beaucoup plus de tokens et sont plus lentes.

---

## Prérequis

- Phase 2 entièrement validée (`.\phase2\validate-phase2.ps1` sans erreurs)
- Docker Desktop en cours d'exécution
- LM Studio en cours d'exécution avec un modèle chargé

---

## Étape 1 — Préparer l'environnement

```powershell
cd phase3

# Créer le fichier .env depuis l'exemple
Copy-Item .env.example .env
```

Ouvrir `.env` et configurer :
- `OPENAI_API_KEY` : laisser `lm-studio` (valeur arbitraire pour LM Studio)
- `LLM_MODEL` : l'ID exact du modèle LM Studio (identique à Phase 1)

---

## Étape 2 — Démarrer OpenHands

```powershell
cd phase3

# Démarrer OpenHands
docker compose up -d

# Vérifier le démarrage (peut prendre 1-2 minutes)
docker compose ps
docker compose logs --tail 30
```

OpenHands sera accessible sur : http://localhost:3001

---

## Étape 3 — Configurer la connexion LM Studio

Dans l'interface OpenHands (http://localhost:3001) > Settings :
- Provider : **OpenAI-Compatible**
- API Base : `http://host.docker.internal:1234/v1`
- API Key : `lm-studio`
- Model : l'ID exact de ton modèle

### Modèles recommandés pour OpenHands

OpenHands fonctionne mieux avec des modèles capables de reasoning.
Avec 16 Go VRAM :
- **Qwen2.5-Coder-14B-Instruct Q4_K_M** : meilleur compromis
- Éviter les modèles < 7B pour les tâches autonomes (trop d'hallucinations)

---

## Utilisation typique avec MealLoop

```
# Dans OpenHands, formuler une tâche autonome claire :

"Read the file lib/services/meal_service.dart and write unit tests
for all public methods. Place tests in test/services/meal_service_test.dart.
Follow the existing test patterns in the test/ folder."
```

**Conseils pour de meilleurs résultats :**
1. Donner une tâche précise avec des fichiers d'entrée/sortie explicites
2. Inclure les conventions dans le prompt ou via les fichiers memory/
3. Commiter avant de lancer OpenHands (pour pouvoir `git diff` facilement)
4. Vérifier le résultat avant d'accepter le commit

---

## Commandes Docker utiles

```powershell
# Voir les logs
docker compose logs -f

# Arrêter
docker compose down

# Redémarrer
docker compose restart

# Mettre à jour
docker compose pull
docker compose up -d
```

---

## Validation Phase 3

```powershell
.\phase3\validate-phase3.ps1
```

---

## Troubleshooting Phase 3

### OpenHands ne se connecte pas à LM Studio

Même cause que Phase 2 — `host.docker.internal` doit résoudre vers Windows.

```powershell
docker exec openhands curl -s http://host.docker.internal:1234/v1/models
```

### OpenHands échoue sur des tâches Flutter

OpenHands a besoin d'un environnement sandbox avec les outils Flutter installés.
Sans configuration supplémentaire, il peut générer du code valide mais ne peut
pas exécuter `flutter test` ou `flutter analyze`.

Pour les tâches qui nécessitent l'exécution locale, préférer **Aider** qui
s'exécute directement dans ton environnement Windows.

### Erreur "sandbox" ou "runtime"

OpenHands utilise Docker-in-Docker pour son sandbox. Vérifier :
1. Docker Desktop a les ressources suffisantes (RAM, CPU)
2. Le mode "Expose daemon on tcp://localhost:2375" est activé dans Docker Desktop

### Modèle trop lent pour les tâches autonomes

Les tâches autonomes génèrent beaucoup d'appels successifs. Si c'est trop lent :
1. Passer au modèle 7B pour OpenHands
2. Réduire la longueur du contexte dans LM Studio
3. Considérer que la tâche est mieux gérée manuellement avec Aider
