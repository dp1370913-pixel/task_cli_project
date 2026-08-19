# task_cli

Application en ligne de commande pour gérer une liste de tâches, écrite en **Dart pur** (sans Flutter).

## Fonctionnalités

- Ajouter une tâche (titre, priorité `low`/`medium`/`high`, date limite optionnelle)
- Ajouter une tâche urgente (toujours priorité `high`, avec une raison d'escalade)
- Lister toutes les tâches, avec tri par priorité ou par date limite
- Marquer une tâche comme terminée
- Supprimer une tâche
- Persister les données dans un fichier JSON local (`tasks.json`)

## Concepts Dart mis en pratique

| Concept | Où le voir |
|---|---|
| Classe abstraite | `Task` (`lib/src/models/task.dart`) |
| Héritage | `StandardTask` et `UrgentTask` héritent de `Task` |
| Interfaces | `Task` implémente `JsonSerializable` et `Comparable<Task>` ; `TaskRepository` implémente `Repository<T>` |
| Génériques | `Repository<T>` (`lib/src/repository/repository.dart`) |
| Exceptions personnalisées | `InvalidTaskException`, `TaskNotFoundException`, `StorageException` (`lib/src/exceptions/`) |
| Programmation asynchrone | `Repository<T>`/`TaskRepository` et `CliRunner` sont entièrement `Future`/`async`/`await`, pour des I/O disque non bloquantes |
| Tests unitaires | 22 tests avec le package `test` (`test/`) |
| Sérialisation JSON | `toJson()` / `fromJson()` sur chaque type de tâche |

## Architecture

```text
lib/
├── src/
│   ├── models/         Task (abstract), StandardTask, UrgentTask, Priority
│   ├── interfaces/     JsonSerializable
│   ├── exceptions/     InvalidTaskException, TaskNotFoundException, StorageException
│   ├── repository/     Repository<T> (interface), TaskRepository (persistance JSON, async)
│   └── cli/             CliRunner (parsing des arguments et orchestration)
└── task_cli.dart       point d'entrée de la librairie (exports)

bin/
└── task_cli.dart       point d'entrée exécutable (main async)

test/
├── task_test.dart              tests des modèles (Task/StandardTask/UrgentTask/Priority)
├── task_repository_test.dart   tests du repository (CRUD + tri, en asynchrone)
└── cli_runner_test.dart        tests de bout en bout sur les commandes CLI
```

- `lib/src/models/` : `Task` est une classe abstraite qui implémente les interfaces `JsonSerializable` et `Comparable<Task>`. `StandardTask` et `UrgentTask` en héritent — une `UrgentTask` est toujours en priorité `high` et doit avoir une raison.
- `lib/src/exceptions/` : exceptions personnalisées, toutes héritant de `TaskException`.
- `lib/src/repository/` : `Repository<T>` est une interface générique (CRUD asynchrone), et `TaskRepository` l'implémente pour lire/écrire les tâches dans le fichier JSON via des I/O `dart:io` non bloquantes (`Future`).
- `lib/src/cli/` : `CliRunner`, qui lit les arguments tapés dans le terminal et appelle la bonne méthode du repository (elle aussi asynchrone).

## Installation

Il faut le [Dart SDK](https://dart.dev/get-dart) (testé avec la version 3.12.2, compatible dès 3.3).

```bash
dart pub get
```

## Lancer l'appli

```bash
dart run bin/task_cli.dart add "Acheter du lait" --priority=high --due=2026-08-25
dart run bin/task_cli.dart add "Corriger le bug en prod" --urgent="Le site est down"
dart run bin/task_cli.dart list --sort=priority
dart run bin/task_cli.dart complete <id>
dart run bin/task_cli.dart delete <id>
dart run bin/task_cli.dart help
```

Le fichier `tasks.json` est créé automatiquement dans le dossier où on lance la commande.

### Les commandes

- `add <titre> [--priority=low|medium|high] [--due=YYYY-MM-DD] [--urgent[=raison]]` — ajoute une tâche. Avec `--urgent`, ça crée une `UrgentTask` (toujours priorité haute).
- `list [--sort=priority|date]` — liste les tâches, avec tri optionnel.
- `complete <id>` — marque une tâche comme terminée.
- `delete <id>` — supprime une tâche.

## Lancer les tests

```bash
dart test
```

22 tests couvrent :
- la création/validation des tâches, la conversion en JSON et retour, le comportement de `UrgentTask` (`test/task_test.dart`) ;
- toutes les opérations asynchrones du `TaskRepository` — ajout, lecture, mise à jour, suppression, tri (`test/task_repository_test.dart`) ;
- le comportement de bout en bout du `CliRunner` — commandes valides, tâche urgente, et gestion des erreurs (commande inconnue, priorité invalide) (`test/cli_runner_test.dart`).

## Vérifier la qualité du code

```bash
dart analyze
```

Doit retourner `No issues found!`.
