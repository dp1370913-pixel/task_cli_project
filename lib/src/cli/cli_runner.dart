import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../models/standard_task.dart';
import '../models/urgent_task.dart';
import '../repository/task_repository.dart';

// Petite classe pour séparer les arguments "libres" (ex: le titre)
// des options du style --priority=high.
class _ParsedOptions {
  final List<String> positional;
  final Map<String, String> named;
  _ParsedOptions(this.positional, this.named);
}

// Lit les arguments passés en ligne de commande et appelle
// la bonne méthode sur le repository.
class CliRunner {
  final TaskRepository repository;

  CliRunner(this.repository);

  void run(List<String> args) {
    if (args.isEmpty) {
      _printUsage();
      return;
    }

    final command = args.first;
    final rest = args.skip(1).toList();

    try {
      if (command == 'add') {
        _handleAdd(rest);
      } else if (command == 'list') {
        _handleList(rest);
      } else if (command == 'complete') {
        _handleComplete(rest);
      } else if (command == 'delete') {
        _handleDelete(rest);
      } else if (command == 'help' || command == '--help' || command == '-h') {
        _printUsage();
      } else {
        stderr.writeln('Commande inconnue: $command');
        _printUsage();
        exitCode = 1;
      }
    } on TaskException catch (e) {
      stderr.writeln('Erreur: ${e.message}');
      exitCode = 1;
    }
  }

  void _handleAdd(List<String> args) {
    if (args.isEmpty) {
      throw InvalidTaskException(
        'Usage: add <titre> [--priority=low|medium|high] [--due=YYYY-MM-DD] [--urgent[=raison]]',
      );
    }

    final options = _parseOptions(args);
    final title = options.positional.join(' ');

    DateTime? dueDate;
    final dueStr = options.named['due'];
    if (dueStr != null) {
      try {
        dueDate = DateTime.parse(dueStr);
      } on FormatException {
        throw InvalidTaskException(
          'Date invalide pour --due: $dueStr (format attendu: YYYY-MM-DD)',
        );
      }
    }

    if (options.named.containsKey('urgent')) {
      final reason = options.named['urgent']!.isNotEmpty
          ? options.named['urgent']!
          : 'Marquée urgente par l\'utilisateur';
      final task = UrgentTask(
        title: title,
        escalationReason: reason,
        dueDate: dueDate,
      );
      repository.add(task);
      print('Tâche urgente ajoutée: "${task.title}" (id: ${task.id})');
    } else {
      final priority = priorityFromString(
        options.named['priority'] ?? 'medium',
      );
      final task = StandardTask(
        title: title,
        priority: priority,
        dueDate: dueDate,
      );
      repository.add(task);
      print('Tâche ajoutée: "${task.title}" (id: ${task.id})');
    }
  }

  void _handleList(List<String> args) {
    final options = _parseOptions(args);
    final sortBy = options.named['sort'];

    var tasks = repository.getAll();
    if (sortBy == 'priority') {
      tasks = repository.sortedByPriority();
    } else if (sortBy == 'date') {
      tasks = repository.sortedByDueDate();
    }

    if (tasks.isEmpty) {
      print('Aucune tâche pour le moment.');
      return;
    }

    for (final task in tasks) {
      print('${task.id}  $task');
    }
  }

  void _handleComplete(List<String> args) {
    if (args.isEmpty) throw InvalidTaskException('Usage: complete <id>');
    final task = repository.getById(args.first);
    task.complete();
    repository.update(task);
    print('Tâche "${task.title}" marquée comme terminée.');
  }

  void _handleDelete(List<String> args) {
    if (args.isEmpty) throw InvalidTaskException('Usage: delete <id>');
    final task = repository.getById(args.first);
    repository.delete(task.id);
    print('Tâche "${task.title}" supprimée.');
  }

  _ParsedOptions _parseOptions(List<String> args) {
    final positional = <String>[];
    final named = <String, String>{};
    for (final arg in args) {
      if (arg.startsWith('--')) {
        final body = arg.substring(2);
        final eqIndex = body.indexOf('=');
        if (eqIndex == -1) {
          named[body] = '';
        } else {
          named[body.substring(0, eqIndex)] = body.substring(eqIndex + 1);
        }
      } else {
        positional.add(arg);
      }
    }
    return _ParsedOptions(positional, named);
  }

  void _printUsage() {
    print('''
Task CLI — gestionnaire de tâches en ligne de commande

Utilisation:
  dart run bin/task_cli.dart add <titre> [--priority=low|medium|high] [--due=YYYY-MM-DD] [--urgent[=raison]]
  dart run bin/task_cli.dart list [--sort=priority|date]
  dart run bin/task_cli.dart complete <id>
  dart run bin/task_cli.dart delete <id>
  dart run bin/task_cli.dart help
''');
  }
}
