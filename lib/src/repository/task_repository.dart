import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import 'repository.dart';

/// [Repository] implementation that persists [Task]s to a local JSON file.
class TaskRepository implements Repository<Task> {
  final File _file;
  List<Task> _tasks = [];

  TaskRepository(String path) : _file = File(path) {
    _load();
  }

  void _load() {
    if (!_file.existsSync()) {
      _tasks = [];
      return;
    }
    final content = _file.readAsStringSync();
    if (content.trim().isEmpty) {
      _tasks = [];
      return;
    }
    try {
      final decoded = jsonDecode(content) as List<dynamic>;
      _tasks = decoded
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException catch (e) {
      throw StorageException('Corrupted task file: ${e.message}');
    }
  }

  void _save() {
    try {
      final data = _tasks.map((t) => t.toJson()).toList();
      if (!_file.parent.existsSync()) {
        _file.parent.createSync(recursive: true);
      }
      _file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
    } on FileSystemException catch (e) {
      throw StorageException('Could not write task file: ${e.message}');
    }
  }

  @override
  void add(Task item) {
    _tasks.add(item);
    _save();
  }

  @override
  List<Task> getAll() => List.unmodifiable(_tasks);

  @override
  Task getById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    throw TaskNotFoundException(id);
  }

  @override
  void update(Task item) {
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) throw TaskNotFoundException(item.id);
    _tasks[index] = item;
    _save();
  }

  @override
  void delete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw TaskNotFoundException(id);
    _tasks.removeAt(index);
    _save();
  }

  List<Task> sortedByPriority() {
    final copy = List<Task>.from(_tasks);
    copy.sort();
    return copy;
  }

  List<Task> sortedByDueDate() {
    final copy = List<Task>.from(_tasks);
    copy.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return copy;
  }
}
