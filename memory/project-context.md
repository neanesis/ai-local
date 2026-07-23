# MealLoop — Contexte Projet

> Charger ce fichier en début de session pour donner le contexte au modèle.

## Identité du projet

> NOTE : Ce fichier est un TEMPLATE à copier dans le repo MealLoop et à remplir.
> Le repo `ai-local` lui-même est l'environnement AI local (voir session-log.md).

**Nom** : MealLoop  
**Type** : Application mobile de planification de repas  
**Plateforme** : Flutter (iOS + Android)  
**Backend** : Supabase  
**Développeur** : Solo developer (neanesis)  

## Stack technique

| Composant      | Technologie            | Notes                          |
|----------------|------------------------|--------------------------------|
| Frontend       | Flutter (Dart)         | [À COMPLÉTER : version Flutter] |
| Backend        | Supabase               | PostgreSQL + Auth + Storage    |
| State management | [À COMPLÉTER]        | ex: Riverpod, Bloc, Provider   |
| Navigation     | [À COMPLÉTER]          | ex: GoRouter, go_router        |
| HTTP / API     | [À COMPLÉTER]          | ex: supabase_flutter, dio      |
| Tests          | [À COMPLÉTER]          | ex: flutter_test, mocktail     |

## Architecture Flutter

```
lib/
├── main.dart
├── app/                    # [À COMPLÉTER : décrire la structure]
├── features/               # ou screens/ ou pages/
│   ├── [feature_1]/
│   └── [feature_2]/
├── shared/                 # ou common/ ou core/
│   ├── models/
│   ├── services/
│   └── widgets/
└── [À COMPLÉTER]
```

## Fonctionnalités principales

[À COMPLÉTER — liste des features existantes et leur état]

Exemple :
- [ ] Planification hebdomadaire de repas
- [ ] Génération de liste de courses
- [ ] Bibliothèque de recettes
- [ ] Authentification utilisateur

## Schéma Supabase (tables principales)

[À COMPLÉTER — description des tables et relations clés]

Exemple :
```sql
-- Table principale
users (id, email, created_at)

-- Tables métier
meal_plans (id, user_id, week_start, created_at)
meals (id, name, category, prep_time, ingredients)
meal_plan_items (id, meal_plan_id, meal_id, day, meal_type)
```

## Règles métier importantes

[À COMPLÉTER — règles de gestion spécifiques à MealLoop]

## Intégrations externes

[À COMPLÉTER — APIs tierces, services Cloud, etc.]

## État actuel du développement

**Version actuelle** : [À COMPLÉTER]  
**Features en cours** : [À COMPLÉTER]  
**Prochaine milestone** : [À COMPLÉTER]

## Points d'attention

[À COMPLÉTER — dette technique, problèmes connus, zones fragiles du code]
