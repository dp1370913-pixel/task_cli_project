import 'dart:io';

import 'package:task_cli/task_cli.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String filePath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('task_cli_test_');
    filePath = '${tempDir.path}/tasks.json';
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('est vide au départ si le fichier n\'existe pas', () {
    final repo = TaskRepository(filePath);
    expect(repo.getAll(), isEmpty);
  });

  test('add() sauvegarde une tâche sur le disque', () {
    final repo = TaskRepository(filePath);
    final task = StandardTask(
      title: 'Écrire le rapport',
      priority: Priority.high,
    );
    repo.add(task);

    expect(repo.getAll(), hasLength(1));
    expect(File(filePath).existsSync(), isTrue);

    final reloaded = TaskRepository(filePath);
    expect(reloaded.getAll().single.title, 'Écrire le rapport');
  });

  test('getById() lève TaskNotFoundException si l\'id n\'existe pas', () {
    final repo = TaskRepository(filePath);
    expect(
      () => repo.getById('missing'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('update() sauvegarde les changements (ex: tâche terminée)', () {
    final repo = TaskRepository(filePath);
    final task = StandardTask(
      title: 'Livrer la fonctionnalité',
      priority: Priority.medium,
    );
    repo.add(task);

    task.complete();
    repo.update(task);

    final reloaded = TaskRepository(filePath);
    expect(reloaded.getById(task.id).isCompleted, isTrue);
  });

  test('delete() supprime une tâche', () {
    final repo = TaskRepository(filePath);
    final task = StandardTask(
      title: 'Tâche temporaire',
      priority: Priority.low,
    );
    repo.add(task);

    repo.delete(task.id);

    expect(repo.getAll(), isEmpty);
    expect(() => repo.getById(task.id), throwsA(isA<TaskNotFoundException>()));
  });

  test('sortedByPriority() trie high puis medium puis low', () {
    final repo = TaskRepository(filePath);
    repo.add(StandardTask(title: 'Basse', priority: Priority.low));
    repo.add(StandardTask(title: 'Haute', priority: Priority.high));
    repo.add(StandardTask(title: 'Moyenne', priority: Priority.medium));

    final sorted = repo.sortedByPriority();
    expect(sorted.map((t) => t.title), ['Haute', 'Moyenne', 'Basse']);
  });

  test(
    'sortedByDueDate() trie par date et met les tâches sans date à la fin',
    () {
      final repo = TaskRepository(filePath);
      repo.add(StandardTask(title: 'Sans date', priority: Priority.low));
      repo.add(
        StandardTask(
          title: 'Plus tard',
          priority: Priority.low,
          dueDate: DateTime(2026, 12, 1),
        ),
      );
      repo.add(
        StandardTask(
          title: 'Plus tôt',
          priority: Priority.low,
          dueDate: DateTime(2026, 9, 1),
        ),
      );

      final sorted = repo.sortedByDueDate();
      expect(sorted.map((t) => t.title), [
        'Plus tôt',
        'Plus tard',
        'Sans date',
      ]);
    },
  );
}
