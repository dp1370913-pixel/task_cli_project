import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../models/standard_task.dart';
import '../models/urgent_task.dart';
import '../repository/task_repository.dart';

class _ParsedOptions {
  final List<String> positional;
  final Map<String, String> named;
  _ParsedOptions(this.positional, this.named);
}

/// Parses command-line arguments and dispatches them to the repository.
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
      switch (command) {
        case 'add':
          _handleAdd(rest);
        case 'list':
          _handleList(rest);
        case 'complete':
          _handleComplete(rest);
        case 'delete':
          _handleDelete(rest);
        case 'help':
        case '--help':
        case '-h':
          _printUsage();
        default:
          stderr.writeln('Unknown command: $command');
          _printUsage();
          exitCode = 1;
      }
    } on TaskException catch (e) {
      stderr.writeln('Error: ${e.message}');
      exitCode = 1;
    }
  }

  void _handleAdd(List<String> args) {
    if (args.isEmpty) {
      throw InvalidTaskException(
        'Usage: add <title> [--priority=low|medium|high] [--due=YYYY-MM-DD] [--urgent[=reason]]',
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
          'Invalid date format for --due: $dueStr (expected YYYY-MM-DD)',
        );
      }
    }

    if (options.named.containsKey('urgent')) {
      final reason = options.named['urgent']!.isNotEmpty
          ? options.named['urgent']!
          : 'Marked urgent by user';
      final task = UrgentTask(
        title: title,
        escalationReason: reason,
        dueDate: dueDate,
      );
      repository.add(task);
      print('Added urgent task "${task.title}" (id: ${task.id})');
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
      print('Added task "${task.title}" (id: ${task.id})');
    }
  }

  void _handleList(List<String> args) {
    final options = _parseOptions(args);
    final sortBy = options.named['sort'];

    final tasks = switch (sortBy) {
      'priority' => repository.sortedByPriority(),
      'date' => repository.sortedByDueDate(),
      _ => repository.getAll(),
    };

    if (tasks.isEmpty) {
      print('No tasks yet.');
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
    print('Marked "${task.title}" as completed.');
  }

  void _handleDelete(List<String> args) {
    if (args.isEmpty) throw InvalidTaskException('Usage: delete <id>');
    final task = repository.getById(args.first);
    repository.delete(task.id);
    print('Deleted "${task.title}".');
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
Task CLI — a simple task manager

Usage:
  dart run bin/task_cli.dart add <title> [--priority=low|medium|high] [--due=YYYY-MM-DD] [--urgent[=reason]]
  dart run bin/task_cli.dart list [--sort=priority|date]
  dart run bin/task_cli.dart complete <id>
  dart run bin/task_cli.dart delete <id>
  dart run bin/task_cli.dart help
''');
  }
}
