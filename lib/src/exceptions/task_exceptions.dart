// Exception "mère" : toutes les autres en héritent.
class TaskException implements Exception {
  final String message;

  TaskException(this.message);

  @override
  String toString() => message;
}

// Levée quand une tâche est invalide (titre vide, priorité inconnue, etc).
class InvalidTaskException extends TaskException {
  InvalidTaskException(super.message);
}

// Levée quand on cherche une tâche avec un id qui n'existe pas.
class TaskNotFoundException extends TaskException {
  TaskNotFoundException(String id) : super('Tâche introuvable: $id');
}

// Levée si le fichier tasks.json ne peut pas être lu ou écrit.
class StorageException extends TaskException {
  StorageException(super.message);
}
