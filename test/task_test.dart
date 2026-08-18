import 'package:task_cli/task_cli.dart';
import 'package:test/test.dart';

void main() {
  group('StandardTask', () {
    test('crée une tâche et la reconstruit depuis son JSON', () {
      final task = StandardTask(
        title: 'Acheter du lait',
        priority: Priority.medium,
      );
      final json = task.toJson();
      final restored = Task.fromJson(json);

      expect(restored, isA<StandardTask>());
      expect(restored.title, 'Acheter du lait');
      expect(restored.priority, Priority.medium);
      expect(restored.isCompleted, isFalse);
    });

    test('lève InvalidTaskException si le titre est vide', () {
      expect(
        () => StandardTask(title: '   ', priority: Priority.low),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('complete() marque la tâche comme terminée', () {
      final task = StandardTask(title: 'Lire un livre', priority: Priority.low);
      expect(task.isCompleted, isFalse);
      task.complete();
      expect(task.isCompleted, isTrue);
    });
  });

  group('UrgentTask', () {
    test('est toujours en priorité haute', () {
      final task = UrgentTask(
        title: 'Corriger le bug en prod',
        escalationReason: 'Le site est down',
      );
      expect(task.priority, Priority.high);
    });

    test('demande une raison non vide', () {
      expect(
        () => UrgentTask(title: 'Fix bug', escalationReason: ''),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('garde sa raison après un aller-retour JSON', () {
      final task = UrgentTask(
        title: 'Serveur down',
        escalationReason: 'Clients impactés',
      );
      final restored = Task.fromJson(task.toJson());

      expect(restored, isA<UrgentTask>());
      expect((restored as UrgentTask).escalationReason, 'Clients impactés');
    });
  });

  group('Task.compareTo', () {
    test('trie la priorité haute avant la priorité basse', () {
      final high = StandardTask(title: 'A', priority: Priority.high);
      final low = StandardTask(title: 'B', priority: Priority.low);
      expect(high.compareTo(low), lessThan(0));
    });
  });

  group('priorityFromString', () {
    test('parse les priorités sans tenir compte de la casse', () {
      expect(priorityFromString('HIGH'), Priority.high);
      expect(priorityFromString('low'), Priority.low);
    });

    test('lève InvalidTaskException pour une priorité inconnue', () {
      expect(
        () => priorityFromString('urgent-ish'),
        throwsA(isA<InvalidTaskException>()),
      );
    });
  });
}
