import 'priority.dart';
import 'task.dart';

// Une tâche "normale", avec la priorité choisie par l'utilisateur.
class StandardTask extends Task {
  StandardTask({
    required super.title,
    required super.priority,
    super.dueDate,
    super.id,
    super.isCompleted,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': 'standard',
    'id': id,
    'title': title,
    'priority': priority.name,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StandardTask.fromJson(Map<String, dynamic> json) => StandardTask(
    id: json['id'] as String,
    title: json['title'] as String,
    priority: priorityFromString(json['priority'] as String),
    dueDate: json['dueDate'] != null
        ? DateTime.parse(json['dueDate'] as String)
        : null,
    isCompleted: json['isCompleted'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
