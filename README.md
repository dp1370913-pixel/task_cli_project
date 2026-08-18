# task_cli

Petite appli en ligne de commande pour gérer une liste de tâches, faite en Dart pur (pas de Flutter).

## Ce que ça fait

- Ajouter une tâche (titre, priorité low/medium/high, date limite optionnelle)
- Lister les tâches, avec un tri par priorité ou par date
- Marquer une tâche comme terminée
- Supprimer une tâche
- Les tâches sont sauvegardées dans un fichier `tasks.json`

## Comment c'est organisé

- `lib/src/models/` : `Task` est une classe abstraite (elle implémente les interfaces `JsonSerializable` et `Comparable<Task>`). `StandardTask` et `UrgentTask` en héritent — une `UrgentTask` est toujours en priorité `high` et doit avoir une raison.
- `lib/src/exceptions/` : mes exceptions perso (`InvalidTaskException`, `TaskNotFoundException`, `StorageException`).
- `lib/src/repository/` : `Repository<T>` est une interface générique (CRUD), et `TaskRepository` l'implémente pour lire/écrire les tâches dans le fichier JSON.
- `lib/src/cli/` : `CliRunner`, qui lit les arguments tapés dans le terminal et appelle le bon truc.

## Installation

Il faut le [Dart SDK](https://dart.dev/get-dart) (testé avec la version 3.12.2).

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

Les tests couvrent la création/validation des tâches, la conversion en JSON et retour, le comportement de `UrgentTask`, et toutes les opérations du `TaskRepository` (ajout, lecture, mise à jour, suppression, tri).
