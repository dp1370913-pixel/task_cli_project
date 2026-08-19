import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import 'repository.dart';

// Implémentation de Repository<Task> qui sauvegarde les tâches
// dans un fichier JSON local. La lecture/écriture se fait de façon
// asynchrone (dart:io File.readAsString/writeAsString) pour ne pas
// bloquer l'exécution pendant les I/O disque.
class TaskRepository implements Repository<Task> {
  final File _file;
  final List<Task> _tasks;

  TaskRepository._(this._file, this._tasks);

  // Factory asynchrone : on ne peut pas faire d'`await` dans un
  // constructeur classique, donc le chargement initial passe par ici.
  static Future<TaskRepository> create(String path) async {
    final file = File(path);
    final tasks = await _loadFrom(file);
    return TaskRepository._(file, tasks);
  }

  static Future<List<Task>> _loadFrom(File file) async {
    if (!await file.exists()) {
      return [];
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(content) as List<dynamic>;
      return decoded
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException('Fichier tasks.json corrompu: $e');
    }
  }

  Future<void> _save() async {
    try {
      final data = _tasks.map((t) => t.toJson()).toList();
      if (!await _file.parent.exists()) {
        await _file.parent.create(recursive: true);
      }
      await _file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );
    } catch (e) {
      throw StorageException('Impossible d\'écrire dans tasks.json: $e');
    }
  }

  @override
  Future<void> add(Task item) async {
    _tasks.add(item);
    await _save();
  }

  @override
  Future<List<Task>> getAll() async => List<Task>.from(_tasks);

  @override
  Future<Task> getById(String id) async {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    throw TaskNotFoundException(id);
  }

  @override
  Future<void> update(Task item) async {
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) throw TaskNotFoundException(item.id);
    _tasks[index] = item;
    await _save();
  }

  @override
  Future<void> delete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw TaskNotFoundException(id);
    _tasks.removeAt(index);
    await _save();
  }

  Future<List<Task>> sortedByPriority() async {
    final copy = List<Task>.from(_tasks);
    copy.sort();
    return copy;
  }

  Future<List<Task>> sortedByDueDate() async {
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
