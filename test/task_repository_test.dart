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

  test('starts empty when no file exists yet', () {
    final repo = TaskRepository(filePath);
    expect(repo.getAll(), isEmpty);
  });

  test('add() persists a task to disk and getAll() returns it', () {
    final repo = TaskRepository(filePath);
    final task = StandardTask(title: 'Write report', priority: Priority.high);
    repo.add(task);

    expect(repo.getAll(), hasLength(1));
    expect(File(filePath).existsSync(), isTrue);

    final reloaded = TaskRepository(filePath);
    expect(reloaded.getAll().single.title, 'Write report');
  });

  test('getById() throws TaskNotFoundException for a missing id', () {
    final repo = TaskRepository(filePath);
    expect(
      () => repo.getById('missing'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('update() persists changes such as completion', () {
    final repo = TaskRepository(filePath);
    final task = StandardTask(title: 'Ship feature', priority: Priority.medium);
    repo.add(task);

    task.complete();
    repo.update(task);

    final reloaded = TaskRepository(filePath);
    expect(reloaded.getById(task.id).isCompleted, isTrue);
  });

  test('delete() removes a task', () {
    final repo = TaskRepository(filePath);
    final task = StandardTask(title: 'Temp task', priority: Priority.low);
    repo.add(task);

    repo.delete(task.id);

    expect(repo.getAll(), isEmpty);
    expect(() => repo.getById(task.id), throwsA(isA<TaskNotFoundException>()));
  });

  test('sortedByPriority() orders high before medium before low', () {
    final repo = TaskRepository(filePath);
    repo.add(StandardTask(title: 'Low', priority: Priority.low));
    repo.add(StandardTask(title: 'High', priority: Priority.high));
    repo.add(StandardTask(title: 'Medium', priority: Priority.medium));

    final sorted = repo.sortedByPriority();
    expect(sorted.map((t) => t.title), ['High', 'Medium', 'Low']);
  });

  test('sortedByDueDate() orders soonest first and pushes null dates last', () {
    final repo = TaskRepository(filePath);
    repo.add(StandardTask(title: 'No date', priority: Priority.low));
    repo.add(
      StandardTask(
        title: 'Later',
        priority: Priority.low,
        dueDate: DateTime(2026, 12, 1),
      ),
    );
    repo.add(
      StandardTask(
        title: 'Sooner',
        priority: Priority.low,
        dueDate: DateTime(2026, 9, 1),
      ),
    );

    final sorted = repo.sortedByDueDate();
    expect(sorted.map((t) => t.title), ['Sooner', 'Later', 'No date']);
  });
}
