/// Base type for every exception raised by this application.
class TaskException implements Exception {
  final String message;

  TaskException(this.message);

  @override
  String toString() => message;
}

/// Raised when a task fails validation (empty title, bad priority, ...).
class InvalidTaskException extends TaskException {
  InvalidTaskException(super.message);
}

/// Raised when looking up, updating or deleting a task that doesn't exist.
class TaskNotFoundException extends TaskException {
  TaskNotFoundException(String id) : super('Task not found: $id');
}

/// Raised when the JSON storage file can't be read or written.
class StorageException extends TaskException {
  StorageException(super.message);
}
