class Todo {
  int id;
  String name;
  DateTime time;
  bool isDone = false;
  Todo(this.id, this.name, this.time);
  @override
  String toString() {
    return 'name: $name, time: $time';
  }
}
