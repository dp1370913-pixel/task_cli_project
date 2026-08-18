import 'package:task_cli/task_cli.dart';
import 'package:test/test.dart';

void main() {
  group('StandardTask', () {
    test('creates a task and round-trips through JSON', () {
      final task = StandardTask(title: 'Buy milk', priority: Priority.medium);
      final json = task.toJson();
      final restored = Task.fromJson(json);

      expect(restored, isA<StandardTask>());
      expect(restored.title, 'Buy milk');
      expect(restored.priority, Priority.medium);
      expect(restored.isCompleted, isFalse);
    });

    test('throws InvalidTaskException for an empty title', () {
      expect(
        () => StandardTask(title: '   ', priority: Priority.low),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('complete() marks the task as completed', () {
      final task = StandardTask(title: 'Read a book', priority: Priority.low);
      expect(task.isCompleted, isFalse);
      task.complete();
      expect(task.isCompleted, isTrue);
    });
  });

  group('UrgentTask', () {
    test('is always high priority regardless of what is passed', () {
      final task = UrgentTask(
        title: 'Fix production bug',
        escalationReason: 'Site is down',
      );
      expect(task.priority, Priority.high);
    });

    test('requires a non-empty escalation reason', () {
      expect(
        () => UrgentTask(title: 'Fix bug', escalationReason: ''),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('round-trips through JSON with its escalation reason', () {
      final task = UrgentTask(
        title: 'Server down',
        escalationReason: 'Customers affected',
      );
      final restored = Task.fromJson(task.toJson());

      expect(restored, isA<UrgentTask>());
      expect((restored as UrgentTask).escalationReason, 'Customers affected');
    });
  });

  group('Task.compareTo', () {
    test('orders high priority before low priority', () {
      final high = StandardTask(title: 'A', priority: Priority.high);
      final low = StandardTask(title: 'B', priority: Priority.low);
      expect(high.compareTo(low), lessThan(0));
    });
  });

  group('priorityFromString', () {
    test('parses valid priority strings case-insensitively', () {
      expect(priorityFromString('HIGH'), Priority.high);
      expect(priorityFromString('low'), Priority.low);
    });

    test('throws InvalidTaskException for an unknown priority', () {
      expect(
        () => priorityFromString('urgent-ish'),
        throwsA(isA<InvalidTaskException>()),
      );
    });
  });
}
