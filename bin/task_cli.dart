import 'package:task_cli/task_cli.dart';

Future<void> main(List<String> args) async {
  final repository = await TaskRepository.create('tasks.json');
  final runner = CliRunner(repository);
  await runner.run(args);
}
