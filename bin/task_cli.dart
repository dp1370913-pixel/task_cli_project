import 'package:task_cli/task_cli.dart';

void main(List<String> args) {
  final repository = TaskRepository('tasks.json');
  final runner = CliRunner(repository);
  runner.run(args);
}
