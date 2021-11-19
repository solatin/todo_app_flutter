import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todos_app/models/todo.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Todo> _todoList = <Todo>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: ListView(children: _getItems()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create');
          if (result != null) {
            _addTodoItem(result as Todo);
          }
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  void _addTodoItem(Todo newTodo) {
    //Wrapping it inside a set state will notify
    // the app that the state has changed

    setState(() {
      _todoList.add(newTodo);
    });
  }

  Widget _buildTodoItem(Todo todo) {
    return ListTile(
      title: Text('${todo.name}'),
      leading: Icon(Icons.soap),
      subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(todo.time)),
    );
  }

  List<Widget> _getItems() {
    final List<Widget> _todoWidgets = <Widget>[];
    for (Todo todo in _todoList) {
      _todoWidgets.add(_buildTodoItem(todo));
    }
    return _todoWidgets;
  }
}
