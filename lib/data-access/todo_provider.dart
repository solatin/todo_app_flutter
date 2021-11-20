// ignore_for_file: await_only_futures

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todos_app/models/todo.dart';

class TodoDAO {
  Database? database;
  final databaseName = 'todo.db';

  Future<void> open(String dbName) async {
    database = await openDatabase(join(await getDatabasesPath(), dbName),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          'create table Todo(todoID integer primary key, name text, time text, isDone integer)');
    });
  }

  Future<void> close() async => database?.close();

  void insert(Todo todo) async {
    await open(databaseName);
    print('insert $todo');
    await database?.insert('Todo', todo.toMap());
    await close();
  }

  void update(Todo todo) async {
    await open(databaseName);
    await database?.update('Todo', todo.toMap(),
        where: 'todoID = ?', whereArgs: [todo.id]);
    await close();
  }

  void delete(int id) async {
    await open(databaseName);
    await database?.delete('Todo', where: 'todoID = ?', whereArgs: [id]);
    await close();
  }

  Future<List<Todo>> getTodos() async {
    await open(databaseName);
    List<Map<String, dynamic>>? maps = await database?.query('Todo');
    await close();
    return List.generate(
        maps!.length,
        (index) => Todo(
            maps[index]['todoID'],
            maps[index]['name'],
            DateTime.parse(maps[index]['time']),
            maps[index]['isDone'] == 1 ? true : false));
  }
}
