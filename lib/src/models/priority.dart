import '../exceptions/task_exceptions.dart';

enum Priority { low, medium, high }

Priority priorityFromString(String value) {
  switch (value.toLowerCase()) {
    case 'low':
      return Priority.low;
    case 'medium':
      return Priority.medium;
    case 'high':
      return Priority.high;
    default:
      throw InvalidTaskException(
        'Priorité inconnue "$value" (attendu: low, medium ou high)',
      );
  }
}
