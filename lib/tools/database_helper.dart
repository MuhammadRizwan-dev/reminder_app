import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        time TEXT,
        date TEXT
      )
    ''');
  }
  Future<int> insertReminder(String title, String time, String date) async {
    final db = await instance.database;
    return await db.insert('reminders', {
      'title': title,
      'time': time,
      'date': date,
    });
  }
  Future<List<Map<String, dynamic>>> fetchReminders() async {
    final db = await instance.database;
    return await db.query('reminders', orderBy: 'id DESC');
  }
  Future<int> deleteReminder(int id) async {
    final db = await instance.database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}