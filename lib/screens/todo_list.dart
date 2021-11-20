import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todos_app/data-access/todo_provider.dart';
import 'package:todos_app/models/todo.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todos_app/models/todo.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isDateAfter(DateTime other) {
    return year > other.year ||
        month > other.month ||
        (year == other.year && month == other.month && day > other.day);
  }
}

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Todo> _todoList = <Todo>[];
  final List<String> listFilter = ['All', 'Today', 'Upcoming'];
  String activeFilter = 'All';
  String searchTerm = '';
  int count = 0;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    final todoDAO = new TodoDAO();
    todoDAO.getTodos().then((value) {
      setState(() {
        _todoList = value;
        count = value.last.id + 1;
      });
    });
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = const IOSInitializationSettings();
    var initSetttings = InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: (String? payload) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List'),
        ),
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
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: TextField(
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          hintText: 'Search todo',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 15.0)),
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _getFilters(),
                    ),
                  ),
                  Expanded(
                    child: ListView(children: _getItems()),
                  ),
                ])));
  }

  scheduleNotification(Todo todo) async {
    var android = const AndroidNotificationDetails('channel id', 'channel NAME',
        priority: Priority.high, importance: Importance.max);
    var iOS = const IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);

    final tz.TZDateTime todoTZTime = tz.TZDateTime.from(todo.time, tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        todoTZTime.year,
        todoTZTime.month,
        todoTZTime.day,
        todoTZTime.hour,
        todoTZTime.minute - 10);
    await flutterLocalNotificationsPlugin.zonedSchedule(todo.id,
        'Ongoing todo in 10 minutes', todo.name, scheduledDate, platform,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  List<Widget> _getFilters() {
    List<Widget> list = [];
    int i = 0;
    for (i = 0; i < listFilter.length; i++) {
      final filter = listFilter[i];
      list.add(Padding(
          padding: const EdgeInsets.only(right: 4),
          child: ActionChip(
              onPressed: () {
                setState(() {
                  activeFilter = filter;
                });
              },
              label: Text(
                listFilter[i],
                style: TextStyle(
                    color: listFilter[i] == activeFilter
                        ? Colors.blue
                        : Colors.black,
                    fontWeight: FontWeight.w400),
              ),
              backgroundColor: listFilter[i] == activeFilter
                  ? Colors.blue[50]
                  : Colors.grey.shade300,
              shape: const StadiumBorder(
                  side: BorderSide(width: 0.3, color: Colors.grey)))));
    }
    return list;
  }

  void _addTodoItem(Todo unIndexedTodo) {
    Todo newTodo = Todo(count, unIndexedTodo.name, unIndexedTodo.time, false);
    setState(() {
      _todoList.add(newTodo);
      count += 1;
    });
    final todoDAO = new TodoDAO();
    todoDAO.insert(newTodo);
    scheduleNotification(newTodo);
  }

  void _removeTodoItem(Todo todo) async {
    setState(() {
      _todoList.remove(todo);
    });
    final todoDAO = new TodoDAO();
    todoDAO.delete(todo.id);
    await flutterLocalNotificationsPlugin.cancel(todo.id);
  }

  void _checkDoneTodo(Todo todo) async {
    todo.isDone = true;
    final todoDAO = new TodoDAO();
    todoDAO.update(todo);
    setState(() {});
  }

  Widget _buildTodoItem(Todo todo) {
    return ListTile(
        title: Text('${todo.name}'),
        leading: todo.isDone
            ? IconButton(
                onPressed: () {},
                icon: Icon(Icons.check_box_sharp, color: Colors.black12))
            : IconButton(
                onPressed: () {
                  _checkDoneTodo(todo);
                },
                icon: Icon(Icons.check_box_outline_blank_rounded)),
        subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(todo.time)),
        enabled: !todo.isDone,
        trailing: todo.isDone
            ? TextButton(
                onPressed: () {
                  _removeTodoItem(todo);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ))
            : null);
  }

  List<Widget> _getItems() {
    final DateTime TODAY = DateTime.now();
    final List<Widget> _todoWidgets = <Widget>[];
    for (Todo todo in _todoList) {
      if (((activeFilter == 'Today' && todo.time.isSameDate(TODAY)) ||
              (activeFilter == 'Upcoming' && todo.time.isDateAfter(TODAY)) ||
              activeFilter == 'All') &&
          todo.name.contains(searchTerm)) {
        _todoWidgets.add(_buildTodoItem(todo));
      }
    }
    return _todoWidgets;
  }
}
