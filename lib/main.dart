import 'package:flutter/material.dart';
import 'package:todos_app/screens/create_todo.dart';
import 'package:todos_app/screens/notif.dart';
import 'package:todos_app/screens/todo_list.dart';
import 'package:timezone/data/latest_all.dart' as tz;
void main() async {
  tz.initializeTimeZones();
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'To-Do-List',  initialRoute: '/notif',
  routes: {
    '/': (context) => const TodoList(),
    '/create': (context) => const CreateTodo(),
    '/notif': (context) => Notif()
  },
  );
  }
}

