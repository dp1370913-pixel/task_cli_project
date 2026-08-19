import 'dart:math';

import '../exceptions/task_exceptions.dart';
import '../interfaces/json_serializable.dart';
import 'priority.dart';
import 'standard_task.dart';
import 'urgent_task.dart';

abstract class Task implements JsonSerializable, Comparable<Task> {
  final String id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.title,
    required this.priority,
    this.dueDate,
    String? id,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : id = id ?? _generateId(),
       createdAt = createdAt ?? DateTime.now() {
    if (title.trim().isEmpty) {
      throw InvalidTaskException('Le titre de la tâche ne peut pas être vide');
    }
  }

  static String _generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = Random().nextInt(46656).toRadixString(36).padLeft(3, '0');
    return '$timestamp$salt';
  }

  void complete() {
    isCompleted = true;
  }

  @override
  int compareTo(Task other) => other.priority.index.compareTo(priority.index);

  @override
  Map<String, dynamic> toJson();

  static Task fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'standard';
    if (type == 'urgent') {
      return UrgentTask.fromJson(json);
    } else if (type == 'standard') {
      return StandardTask.fromJson(json);
    } else {
      throw StorageException('Type de tâche inconnu: $type');
    }
  }

  @override
  String toString() {
    final due = dueDate != null
        ? ' (avant le ${dueDate!.toIso8601String().split('T').first})'
        : '';
    final mark = isCompleted ? '[x]' : '[ ]';
    return '$mark $title — ${priority.name}$due';
  }
}
