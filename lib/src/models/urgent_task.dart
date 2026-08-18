// Priority is forced to `high` in the constructor below, which requires an
// explicit `super(...)` call — that's incompatible with super parameters.
// ignore_for_file: use_super_parameters

import '../exceptions/task_exceptions.dart';
import 'priority.dart';
import 'task.dart';

/// A task escalated to top priority, e.g. a production incident. Urgent
/// tasks are always [Priority.high] and must carry a reason for the
/// escalation.
class UrgentTask extends Task {
  final String escalationReason;

  UrgentTask({
    required String title,
    required this.escalationReason,
    DateTime? dueDate,
    String? id,
    bool isCompleted = false,
    DateTime? createdAt,
  }) : super(
         title: title,
         priority: Priority.high,
         dueDate: dueDate,
         id: id,
         isCompleted: isCompleted,
         createdAt: createdAt,
       ) {
    if (escalationReason.trim().isEmpty) {
      throw InvalidTaskException(
        'Escalation reason cannot be empty for an urgent task',
      );
    }
  }

  @override
  String get statusLabel => isCompleted ? 'done' : 'URGENT-pending';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'urgent',
    'id': id,
    'title': title,
    'priority': priority.name,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'escalationReason': escalationReason,
  };

  factory UrgentTask.fromJson(Map<String, dynamic> json) => UrgentTask(
    id: json['id'] as String,
    title: json['title'] as String,
    escalationReason: json['escalationReason'] as String,
    dueDate: json['dueDate'] != null
        ? DateTime.parse(json['dueDate'] as String)
        : null,
    isCompleted: json['isCompleted'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  @override
  String toString() => '${super.toString()} — escalated: $escalationReason';
}
