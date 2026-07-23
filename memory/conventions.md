# MealLoop — Conventions de Code

> Charger ce fichier quand le modèle génère du code pour s'assurer de la cohérence.

## Conventions générales

- **Langue du code** : anglais (noms de classes, méthodes, variables)
- **Langue des commentaires** : [À COMPLÉTER : français ou anglais ?]
- **Langue des commits** : [À COMPLÉTER]
- **Style de commits** : [À COMPLÉTER — ex: Conventional Commits]

## Conventions Dart / Flutter

### Nommage

```dart
// Classes : PascalCase
class MealPlanScreen {}
class MealService {}

// Variables et méthodes : camelCase
final mealPlanItems = [];
void fetchMealPlan() {}

// Constantes : lowerCamelCase (pas de SCREAMING_SNAKE)
const defaultPlanDuration = 7;

// Fichiers : snake_case
// meal_plan_screen.dart
// meal_service.dart
```

### Structure d'un widget Flutter

[À COMPLÉTER — pattern préféré : StatelessWidget, ConsumerWidget, etc.]

```dart
// Exemple de pattern utilisé dans le projet
class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return // ...
  }
}
```

### Gestion d'état

[À COMPLÉTER — décrire le pattern utilisé et comment l'appliquer]

### Gestion des erreurs

[À COMPLÉTER — comment les erreurs sont traitées, quel type de résultat]

Exemple :
```dart
// Pattern utilisé : Either / Result / try-catch avec state
// Exemple à compléter selon le projet
```

## Conventions Supabase

### Requêtes

[À COMPLÉTER — patterns standards pour les requêtes Supabase]

```dart
// Exemple de pattern de requête
final response = await supabase
  .from('meal_plans')
  .select()
  .eq('user_id', userId)
  .order('created_at', ascending: false);
```

### Authentification

[À COMPLÉTER — comment l'auth est gérée dans le projet]

## Tests

### Structure des tests

[À COMPLÉTER — où sont les tests, convention de nommage]

```
test/
├── unit/         # Tests unitaires (services, models)
├── widget/       # Tests de widgets
└── integration/  # Tests d'intégration
```

### Pattern de test préféré

[À COMPLÉTER]

## Ce qu'il ne faut PAS faire

[À COMPLÉTER — anti-patterns spécifiques au projet]

Exemples courants :
- Ne pas appeler Supabase directement depuis les widgets
- Ne pas hardcoder les IDs ou URLs
- [À COMPLÉTER selon le projet]

## Imports et dépendances

[À COMPLÉTER — pubspec.yaml, packages préférés, versions importantes]
