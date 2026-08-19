import 'dart:io';

import 'package:task_cli/task_cli.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String filePath;
  late TaskRepository repository;
  late CliRunner runner;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('task_cli_runner_test_');
    filePath = '${tempDir.path}/tasks.json';
    repository = await TaskRepository.create(filePath);
    runner = CliRunner(repository);
    exitCode = 0;
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    exitCode = 0;
  });

  test('add crée une tâche standard avec la priorité demandée', () async {
    await runner.run(['add', 'Acheter du lait', '--priority=high']);

    final tasks = await repository.getAll();
    expect(tasks, hasLength(1));
    expect(tasks.single, isA<StandardTask>());
    expect(tasks.single.title, 'Acheter du lait');
    expect(tasks.single.priority, Priority.high);
    expect(exitCode, 0);
  });

  test('add --urgent crée une UrgentTask en priorité haute', () async {
    await runner.run(['add', 'Site en panne', '--urgent=Prod down']);

    final tasks = await repository.getAll();
    expect(tasks.single, isA<UrgentTask>());
    expect(tasks.single.priority, Priority.high);
    expect(exitCode, 0);
  });

  test('complete marque la tâche comme terminée', () async {
    await runner.run(['add', 'Tâche à finir']);
    final id = (await repository.getAll()).single.id;

    await runner.run(['complete', id]);

    expect((await repository.getById(id)).isCompleted, isTrue);
  });

  test('delete supprime la tâche', () async {
    await runner.run(['add', 'Tâche à supprimer']);
    final id = (await repository.getAll()).single.id;

    await runner.run(['delete', id]);

    expect(await repository.getAll(), isEmpty);
  });

  test('une commande inconnue met exitCode à 1 sans planter', () async {
    await runner.run(['flibbertigibbet']);
    expect(exitCode, 1);
  });

  test('une priorité invalide est rattrapée et met exitCode à 1', () async {
    await runner.run(['add', 'Tâche', '--priority=extreme']);
    expect(exitCode, 1);
    expect(await repository.getAll(), isEmpty);
  });
}
