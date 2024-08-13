import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_sqlite/models/task.dart';

class DatabaseServices {
  static Database? _db;
  static final DatabaseServices instance = DatabaseServices._constructor();

  final String _tasksDbName = 'tasks';
  final String _tasksIdColumnName = 'id';
  final String _tasksContentColumnName = 'content';
  final String _tasksStatusColumnName = 'status';

  DatabaseServices._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(
      databaseDirPath,
      'master_db.db',
    );

    final database =
        await openDatabase(version: 1, databasePath, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE $_tasksDbName (
            $_tasksIdColumnName INTEGER PRIMARY KEY,
            $_tasksContentColumnName TEXT NOT NULL,
            $_tasksStatusColumnName INTEGER NOT NULL 
        )
    ''');
    });

    return database;
  }

  void addTask(String content) async {
    final db = await database;

    await db.insert(_tasksDbName,
        {_tasksContentColumnName: content, _tasksStatusColumnName: 0});
  }

  Future<List<Task>?> getTasks() async {
    final db = await database;

    final data = await db.query(_tasksDbName);

    List<Task> tasks = data
        .map((e) => Task(
            id: e['id'] as int,
            status: e['status'] as int,
            content: e['content'] as String))
        .toList();

    return tasks;
  }

  void updateTaskStatus(int id, int status) async {
    final db = await database;

    await db.update(
      _tasksDbName,
      {_tasksStatusColumnName: status},
      where: 'id = ?',
      whereArgs: [
        id,
      ],
    );
  }

  void deleteTask(int id) async {
    final db = await database;

    await db.delete(
      _tasksDbName,
      where: 'id = ?',
      whereArgs: [
        id,
      ],
    );
  }
}
