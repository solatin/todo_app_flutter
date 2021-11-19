import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:todos_app/models/todo.dart';

class CreateTodo extends StatefulWidget {
  const CreateTodo({Key? key}) : super(key: key);

  @override
  _CreateTodoState createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  DateTime todoTime = DateTime.now();
  final nameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create new todo'),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Todo:', style: TextStyle(fontSize: 18)),
                      SizedBox(
                        width: 12,
                      ),
                      SizedBox(
                        width: 200,
                        child: TextField(
                            controller: nameController,
                            style: TextStyle(
                                fontSize: 16.0,
                                height: 2.0,
                                color: Colors.black)),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Pick time:',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Container(
                        child: TextButton(
                            onPressed: () {
                              DatePicker.showDateTimePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(2020, 5, 5, 20, 50),
                                  maxTime: DateTime(2020, 6, 7, 05, 09),
                                  onConfirm: (date) {
                                setState(() {
                                  todoTime = date;
                                });
                              }, currentTime: todoTime);
                            },
                            child: Text(
                              DateFormat('yyyy-MM-dd – kk:mm').format(todoTime),
                              style: TextStyle(fontSize: 18),
                            )),
                      ),
                    ],
                  ),
                  Container(
                    child: ElevatedButton(
                      child: Text('Submit'),
                      onPressed: () {
                        Navigator.pop(
                            context, Todo(nameController.text, todoTime));
                      },
                    ),
                  )
                ],
              )),
        ));
  }
}
