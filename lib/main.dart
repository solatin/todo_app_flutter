import 'package:flutter/material.dart';
import 'package:todos_app/screens/create_todo.dart';
import 'package:todos_app/screens/todo_list_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'To-Do-List',  initialRoute: '/',
  routes: {
    '/': (context) => const TodoList(),
    '/create': (context) => const CreateTodo(),
  },
  );
  }
}

