# task_cli

A command-line task manager written in pure Dart (no Flutter).

## Features

- Add a task with a title, a priority (`low` / `medium` / `high`) and an optional due date
- List all tasks, sorted by priority or by due date
- Mark a task as completed
- Delete a task
- Data is persisted locally in a `tasks.json` file

## Architecture

- `lib/src/models/` — `Task` is an abstract base class implementing the
  `JsonSerializable` and `Comparable<Task>` interfaces. `StandardTask` and
  `UrgentTask` (always high priority, requires an escalation reason) extend
  it.
- `lib/src/exceptions/` — custom exceptions (`InvalidTaskException`,
  `TaskNotFoundException`, `StorageException`), all implementing `Exception`.
- `lib/src/repository/` — `Repository<T>` is a generic CRUD interface;
  `TaskRepository` implements it for `Task`, backed by a local JSON file.
- `lib/src/cli/` — `CliRunner` parses arguments and dispatches commands.

## Requirements

- [Dart SDK](https://dart.dev/get-dart) `^3.12.2`

## Getting started

Install dependencies:

```bash
dart pub get
```

## Running the app

```bash
dart run bin/task_cli.dart add "Buy milk" --priority=high --due=2026-08-25
dart run bin/task_cli.dart add "Fix production bug" --urgent="Site is down"
dart run bin/task_cli.dart list --sort=priority
dart run bin/task_cli.dart complete <id>
dart run bin/task_cli.dart delete <id>
dart run bin/task_cli.dart help
```

Tasks are stored in a `tasks.json` file created next to where the command is
run.

### Commands

| Command | Description |
| --- | --- |
| `add <title> [--priority=low\|medium\|high] [--due=YYYY-MM-DD] [--urgent[=reason]]` | Add a task. `--urgent` creates an `UrgentTask` (always high priority). |
| `list [--sort=priority\|date]` | List all tasks, optionally sorted. |
| `complete <id>` | Mark a task as completed. |
| `delete <id>` | Delete a task. |

## Running the tests

```bash
dart test
```

The test suite covers task creation and validation, JSON round-tripping,
inheritance behavior of `UrgentTask`, and every `TaskRepository` operation
(add, get, update, delete, sorting) against a temporary JSON file.
