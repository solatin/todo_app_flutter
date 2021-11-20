import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todos_app/models/todo.dart';
import 'package:todos_app/screens/notif.dart';
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
  final List<Todo> _todoList = <Todo>[];
  final List<String> listFilter = ['All', 'Today', 'Upcoming'];
  String activeFilter = 'All';
  String searchTerm = '';

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
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
                      autofocus: true,
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

  scheduleNotification(int index, Todo todo) async {
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
        todoTZTime.minute -1);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        index, 'Ongoing todo in 10 minutes', todo.name, scheduledDate, platform,
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

  void _addTodoItem(Todo newTodo) {
    setState(() {
      _todoList.add(newTodo);
    });
    scheduleNotification(_todoList.length, newTodo);
  }

  Widget _buildTodoItem(Todo todo) {
    return ListTile(
      title: Text('${todo.name}'),
      leading: Icon(Icons.soap),
      subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(todo.time)),
    );
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
