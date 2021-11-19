class Todo {
  String name;
  DateTime time;
  Todo(this.name, this.time);
  @override
  String toString() {
    return 'name: $name, time: $time';
  }
}
