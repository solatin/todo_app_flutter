class Todo {
  int id;
  String name;
  DateTime time;
  bool isDone = false;
  Todo(this.id, this.name, this.time, this.isDone);
  @override
  String toString() {
    return 'id: $id, name: $name, time: $time';
  }

  Map<String, dynamic> toMap() {
    return {'todoID': id, 'name': name, 'time': time.toString(), 'isDone': isDone ? 1 : 0};
  }
}
