import '../exceptions/task_exceptions.dart';
import '../interfaces/json_serializable.dart';
import 'priority.dart';
import 'standard_task.dart';
import 'urgent_task.dart';

// Classe abstraite : on ne peut pas faire "Task(...)" directement,
// il faut passer par une sous-classe (StandardTask ou UrgentTask).
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
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now() {
    if (title.trim().isEmpty) {
      throw InvalidTaskException('Le titre de la tâche ne peut pas être vide');
    }
  }

  void complete() {
    isCompleted = true;
  }

  // Utilisé par List.sort() pour trier les tâches (interface Comparable).
  // Priorité haute en premier.
  @override
  int compareTo(Task other) => other.priority.index.compareTo(priority.index);

  @override
  Map<String, dynamic> toJson();

  // Reconstruit une StandardTask ou une UrgentTask selon le champ "type"
  // du JSON.
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
