import 'dart:math';

import '../exceptions/task_exceptions.dart';
import '../interfaces/json_serializable.dart';
import 'priority.dart';
import 'standard_task.dart';
import 'urgent_task.dart';

/// Base type for every task. Concrete tasks are [StandardTask] and
/// [UrgentTask].
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
      throw InvalidTaskException('Task title cannot be empty');
    }
  }

  static String _generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = Random().nextInt(46656).toRadixString(36).padLeft(3, '0');
    return '$timestamp$salt';
  }

  void complete() => isCompleted = true;

  String get statusLabel => isCompleted ? 'done' : 'pending';

  bool get isOverdue =>
      !isCompleted && dueDate != null && dueDate!.isBefore(DateTime.now());

  /// Highest priority sorts first.
  @override
  int compareTo(Task other) => other.priority.index.compareTo(priority.index);

  @override
  Map<String, dynamic> toJson();

  static Task fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'standard';
    return switch (type) {
      'urgent' => UrgentTask.fromJson(json),
      'standard' => StandardTask.fromJson(json),
      _ => throw StorageException('Unknown task type: $type'),
    };
  }

  @override
  String toString() {
    final due = dueDate != null
        ? ' (due: ${dueDate!.toIso8601String().split('T').first})'
        : '';
    final mark = isCompleted ? '[x]' : '[ ]';
    return '$mark $title — ${priority.name}$due';
  }
}
